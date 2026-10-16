#!/usr/bin/env bash
# Render / test the Paperclip app against a checkout of truenas/apps.
# Usage: scripts/test-local.sh [render|test]   (default: render)
# Requires: git, docker, python3 with pyyaml pydantic bcrypt psutil
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${TRUENAS_APPS_DIR:-$ROOT/.cache/truenas-apps}"
MODE="${1:-render}"

if [ ! -d "$WORK/.git" ]; then
  git clone --depth 1 https://github.com/truenas/apps.git "$WORK"
else
  git -C "$WORK" pull --ff-only -q
fi

DEST="$WORK/ix-dev/community/paperclip"
mkdir -p "$DEST"
cp -R "$ROOT/ix-dev/community/paperclip/." "$DEST/"

cd "$WORK"
python3 .github/scripts/port_validation.py
case "$MODE" in
  render) python3 .github/scripts/ci.py --app paperclip --train community --test-file basic-values.yaml --render-only true ;;
  test)   python3 .github/scripts/ci.py --app paperclip --train community --test-file basic-values.yaml ;;
  *) echo "usage: $0 [render|test]" >&2; exit 2 ;;
esac
