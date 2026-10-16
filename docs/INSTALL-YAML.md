# Install with the standalone compose file (no catalog needed)

Works on TrueNAS 25.04+ (Docker based Apps) while Paperclip is not yet in the official catalog.

1. Open [`docker-compose.yaml`](../docker-compose.yaml) and change **one line**: `PAPERCLIP_PUBLIC_URL`
   to your server address as you type it in the browser, e.g. `http://192.168.1.10:30528`.
   (Paperclip only accepts requests for hostnames it knows about, so this cannot be guessed.)
2. In TrueNAS: **Apps > Discover Apps > ⋮ (top right) > Install via YAML**, name it `paperclip`, paste the file, save.
3. Open that address and sign in. The first sign-in claims the instance as admin.

Defaults that need no setup: the session and tool-action signing secrets are generated on first start and kept in
the data volume; the database password is `paperclip` (Postgres is not published); data lives in Docker-managed volumes.

Optional: to store data in your own datasets, swap the two volume lines for host paths such as
`/mnt/tank/apps/paperclip/data:/paperclip` and `/mnt/tank/apps/paperclip/postgres:/var/lib/postgresql`.

Then follow the rest of [INSTALL.md](INSTALL.md) (agents, troubleshooting).
