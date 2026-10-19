#!/usr/bin/env bash
# Install smoke test for the standalone docker-compose.yaml.
# Substitutes the one address placeholder, starts the stack, waits for /api/health,
# restarts Paperclip to prove data survives, then tears everything down.
# Requires: docker (with compose v2), curl.   Usage: scripts/smoke-compose.sh [host-port]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${1:-38100}"
WORK="$(mktemp -d)"
PROJECT="pcsmoke$$"
COMPOSE="$WORK/compose.yaml"

dc() { docker compose -f "$COMPOSE" -p "$PROJECT" "$@"; }
cleanup() {
  status=$?
  if [ "$status" -ne 0 ]; then
    echo "::group::container logs"; dc logs --no-color --tail 80 || true; echo "::endgroup::"
  fi
  dc down -v --remove-orphans >/dev/null 2>&1 || true
  rm -rf "$WORK" 2>/dev/null || true
  exit "$status"
}
trap cleanup EXIT

sed \
  -e "s#http://<truenas-ip>:30530#http://localhost:$PORT#" \
  -e "s#\"30530:3100\"#\"$PORT:3100\"#" \
  "$ROOT/docker-compose.yaml" > "$COMPOSE"

if grep -v -E '^[[:space:]]*#' "$COMPOSE" | grep -n -E 'CHANGE_ME|<truenas-ip>'; then
  echo "unsubstituted placeholder left in compose file" >&2; exit 1
fi

# /api/health answers 200 with "status":"starting" while startup recovery runs,
# so wait for "ok" rather than for the first successful response.
wait_healthy() {
  for _ in $(seq 1 90); do
    if curl -fsS -m 3 "http://localhost:$PORT/api/health" -o "$WORK/health.json" 2>/dev/null \
       && grep -q '"status":"ok"' "$WORK/health.json"; then return 0; fi
    sleep 3
  done
  echo "Paperclip did not report status ok within 270s; last response:" >&2
  cat "$WORK/health.json" >&2 2>/dev/null || true
  return 1
}

dc config -q
dc up -d
wait_healthy
curl -fsS -m 5 "http://localhost:$PORT/" -o "$WORK/index.html" && grep -qi "<title>" "$WORK/index.html" || { echo "UI did not load" >&2; exit 1; }

# the app must not be running as root after the entrypoint drops privileges
uid="$(dc exec -T paperclip sh -c 'for p in /proc/[0-9]*; do if tr "\0" " " < "$p/cmdline" 2>/dev/null | grep -q "^node .*server/dist/index.js"; then awk "/^Uid/{print \$2}" "$p/status"; fi; done; true' | head -1 || true)"
[ "$uid" = "568" ] || { echo "expected server uid 568, got '$uid'" >&2; exit 1; }

# graceful stop: tini must be able to signal the node process (needs CAP_KILL)
dc stop paperclip
if dc logs --no-color paperclip | grep -q "FATAL tini"; then echo "tini failed to forward the stop signal" >&2; exit 1; fi
dc start paperclip

# restart: migrations + existing data dir must come back healthy
dc restart paperclip
wait_healthy

# recreate (what TrueNAS does on stop/start or edit): database contents must survive
dc exec -T postgres psql -qU paperclip -d paperclip -c "create table smoke_marker(x int); insert into smoke_marker values (1);"
dc down
dc up -d
wait_healthy
[ "$(dc exec -T postgres psql -tAU paperclip -d paperclip -c 'select count(*) from smoke_marker')" = "1" ] \
  || { echo "database contents were lost when the containers were recreated" >&2; exit 1; }
echo "OK: standalone compose installs, serves UI/health as uid 568, and keeps its data across restart and recreate"
