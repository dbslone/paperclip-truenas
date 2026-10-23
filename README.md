# Paperclip for TrueNAS

A TrueNAS app definition for [Paperclip](https://paperclip.ing), the open-source control plane for AI agents
(org charts, goals, budgets, tickets and governance for Claude, Codex, Gemini, Cursor and other agents).

The app is written for the official [truenas/apps](https://github.com/truenas/apps) catalog format
(Docker Compose + Jinja2 templates + `questions.yaml` install form), so it can be submitted upstream
to the **community** train and installed from the TrueNAS Apps UI.

## What it deploys

| Container   | Image                                | Purpose                                   |
|-------------|--------------------------------------|-------------------------------------------|
| `paperclip` | `ghcr.io/paperclipai/paperclip`      | Paperclip server + UI (on the WebUI port) |
| `postgres`  | `postgres:17`                        | Database (via the catalog's Postgres dep) |

Storage: one dataset for `/paperclip` (uploads, agent workspaces, local secrets key) and one for Postgres data.

## Install form fields

You must set **Public URL** to your server address (e.g. `http://192.168.1.10:30530`; Paperclip only
serves hostnames it knows about) and the two signing secrets (`openssl rand -hex 32` for each).
The DB password defaults to `paperclip` (Postgres is internal only).
Optional: Allowed Hostnames, Anthropic/OpenAI keys, and the standard TrueNAS network, storage, user/group, labels and resource settings.

## Repository layout

```
ix-dev/community/paperclip/   the app (this is what gets submitted to truenas/apps)
scripts/test-local.sh         render + validate the catalog app against a clone of truenas/apps (Linux)
scripts/smoke-compose.sh      install smoke test for the standalone compose (any OS with Docker)
.github/workflows/ci.yml      CI: runs both of the above on every push/PR and weekly
docs/SUBMITTING.md            how to submit to the official catalog
docker-compose.yaml           standalone compose for Install via YAML
docs/INSTALL-YAML.md          install guide for the standalone compose
docs/INSTALL.md               install guide for the catalog app
```

## Install it today (no catalog needed)

Use the standalone [`docker-compose.yaml`](docker-compose.yaml) with **Apps > Discover Apps > Install via YAML**
on TrueNAS 25.04+. Steps: [docs/INSTALL-YAML.md](docs/INSTALL-YAML.md).

Catalog app definition (for reviewers and the `truenas/apps` PR): [`ix-dev/community/paperclip/`](ix-dev/community/paperclip/).
Once merged upstream, install from the Apps catalog instead: [docs/INSTALL.md](docs/INSTALL.md).

## CI

Every push and PR runs two install tests on GitHub Actions:

1. **Standalone compose**: boots the stack, checks `/api/health` and the UI, verifies the server runs as UID 568, restarts it.
2. **Catalog app**: runs the official `truenas/apps` harness (renderer, port uniqueness, Docker Compose install with both the all-options and the out-of-the-box defaults test values, metadata check).

## Status / caveats

- Image is pinned to a release tag + digest; Renovate in the upstream repo bumps it after merge.
- The catalog app runs Paperclip directly as the configured UID/GID (default 568) with no extra capabilities;
  the catalog's permissions container sets ownership of the data dataset.
- The icon is the upstream Paperclip logo (`assets/icon.png`). The catalog only accepts icons hosted on the TrueNAS CDN, so `app.yaml` points at the CDN path the reviewer will upload it to; until then the catalog app shows a placeholder icon. Screenshots are still to do.
- Verified locally: rendered with the official renderer, and booted on Docker with the same caps/user/Postgres 17 settings. Not yet tested on a live TrueNAS system: please report results in issues.
- `scripts/test-local.sh` needs Linux (the catalog's validator image fails on Docker Desktop for macOS).

License: MIT (app definition). Paperclip itself is MIT licensed.
