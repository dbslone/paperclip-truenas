# Submitting to the official catalog (and sharing with the community)

The app lives in `ix-dev/community/paperclip/`. The official catalog only accepts changes under `ix-dev/` (everything in `trains/` is generated).

## Pre-flight checklist

- [x] App renders with the catalog's own renderer (`apps_render_app`), output reviewed
- [x] Boots against Postgres 17 with `cap_drop: ALL` + six caps (incl. KILL), process runs as UID 568, `/api/health` is 200
- [x] Image + postgres pinned by tag and digest
- [ ] Default port unique: run `.github/scripts/port_validation.py` in your fork (30530 was free on 2026-10-16; re-check)
- [ ] Run full CI on Linux: `.github/scripts/ci.py --app paperclip --train community --test-file basic-values.yaml`
      (does not work in Docker Desktop on macOS: the validator image needs `openat2`)
- [x] Library vendored at 2.3.17 (upstream removes old versions; if CI says `Library version ... not found in hashes`, bump `lib_version` + re-vendor with `apps_catalog_hash_generate` / `devbox run copy-lib`)
- [ ] Install on a real TrueNAS box and click through: install, claim admin, restart, upgrade
- [x] Icon: upstream logo, `assets/icon.png` (180x180 PNG). `app.yaml` already uses the required `media.sys.truenas.net` URL; attach the PNG to the PR so the reviewer uploads it
- [ ] 2-3 screenshots ready to attach to the PR

## Steps

1. Fork https://github.com/truenas/apps and open an issue / draft PR saying you are adding Paperclip (avoids duplicate work).
2. Copy `ix-dev/community/paperclip/` into your fork's `ix-dev/community/`.
3. Run the checks above, commit, open a PR titled `Add Paperclip`. Attach icon and screenshots in the description; a reviewer uploads them to the TrueNAS CDN and gives you the final URLs (update `icon`, `screenshots` in `app.yaml` and `item.yaml`).
4. Address review feedback. After merge, Renovate keeps the image tags current.
5. Optional docs: add a tutorial under `content/resources/` in https://github.com/truenas/apps-market (template: `docs/INSTALL.md` is a good start).

## Reaching the Paperclip community

- Open an issue/discussion in https://github.com/paperclipai/paperclip linking this repo and the PR.
- Publish this repo on GitHub; the README doubles as the pitch.
- Until merged, TrueNAS users can still use **Apps > Discover Apps > Install via YAML** with the compose rendered by `scripts/test-local.sh render`.
