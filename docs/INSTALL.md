# Installing Paperclip on TrueNAS

Requires TrueNAS 25.04 or newer (Docker based Apps).

## 1. Install the app

Once the app is merged in the official catalog, enable the **community** train
(Apps > Discover > Manage Catalogs > Preferred Trains) and search for **Paperclip**.

## 2. Fill in the form

Everything has a working default. **The only thing you must change is the Public URL**: type your server's
address as you open it in the browser, e.g. `http://192.168.1.10:30528` (Paperclip only answers to
hostnames it knows, so it cannot guess this). The form refuses the `<truenas-ip>` placeholder.

| Field | Default | Notes |
|-------|---------|-------|
| Public URL | `http://<truenas-ip>:30528` | **Replace with your address.** Must match scheme, host and port |
| Session / Tool Action Signing Secrets | empty = auto-generated | Created on first start, stored in the app data, kept across updates |
| Database Password | `paperclip` | Postgres is internal only, never published |
| Allowed Hostnames | empty | Extra names you also use (LAN DNS, Tailscale) |
| Anthropic / OpenAI API Key | empty | Optional |
| User / Group ID | 568 (`apps`) | |
| Storage | two auto-created datasets | Use Host Path to bring your own |

## 3. Claim the instance

Open the Public URL. The first sign-in claims the instance as admin (it is first-come, so do this
before sharing the URL). Upstream also documents a CLI fallback that prints a one-time admin invite URL (`paperclipai auth bootstrap-ceo`); I have not verified it inside this image.

## 4. Agents

Agents run inside the container using the bundled Claude, Codex, OpenCode and Gemini CLIs. Provide API keys in
the form, or sign in per agent from the Paperclip UI. Agent workspaces live in the app data dataset.

## Troubleshooting

- **Login loops or redirects to the wrong host**: Public URL does not match the address in your browser; add the other name to Allowed Hostnames.
- **Permission errors on Host Path storage**: the path must be writable by the configured UID/GID (default 568).
- **Slow stop**: Paperclip waits for running agents to settle; TrueNAS caps this at 60 s.
