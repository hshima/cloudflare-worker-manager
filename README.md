# cloudflare-worker-manager

`cwm` is a small bash tool that creates, deploys, deletes and recreates Cloudflare Workers.
It uses [wrangler](https://developers.cloudflare.com/workers/wrangler/), Cloudflare's official CLI.
Each Worker is a normal wrangler project in `workers/<name>/`, so you can also use wrangler directly.

## Requirements

- Node.js 22 or later (wrangler needs it)
- `curl` and `jq` (for `cwm list`, `cwm url` and `setup-env.sh`)

## Setup

1. Install wrangler. The project pins the version in `package.json`:
   ```bash
   npm install
   ```

2. Create a Cloudflare API token with these permissions:

   | Scope | Resource | Access | Why |
   | --- | --- | --- | --- |
   | Account | Workers Scripts | Edit | **Required.** Deploy, delete and list Workers, and read the `workers.dev` subdomain. |
   | Account | Workers KV Storage | Read | Recommended. `wrangler delete` lists KV namespaces after the delete. Without it, wrangler shows an error, but the Worker is deleted. |
   | Account | Account Settings | Read | Optional. Lets wrangler read account details. |
   | Account | Workers AI | Edit | Optional. For Workers AI. |

3. Run the setup script. It asks for the account ID and the token, checks them with the
   Cloudflare API, and writes `.env/cloudflare-claude-worker-manager.sh` (mode 600):
   ```bash
   ./setup-env.sh
   ```

## Usage with cwm

```bash
./cwm create   my-api          # copy the template to workers/my-api/ (first time), then deploy
./cwm deploy   my-api          # deploy after you edit workers/my-api/src/index.js
./cwm recreate my-api          # delete the Worker on Cloudflare, then deploy it again
./cwm delete   my-api          # delete the Worker on Cloudflare; local code stays
./cwm list                     # list the Workers in the account
./cwm url      my-api          # print https://my-api.<subdomain>.workers.dev
./cwm wrangler my-api dev      # run any wrangler command in workers/my-api/ with the credentials
./cwm wrangler my-api tail     # stream live logs
```

## Usage with wrangler directly

`cwm` loads the credentials for you. To use wrangler without `cwm`, load them once per terminal:

```bash
source .env/cloudflare-claude-worker-manager.sh
cd workers/my-api
npx wrangler dev           # run the Worker locally on http://localhost:8787
npx wrangler deploy        # deploy
npx wrangler tail          # stream live logs
npx wrangler versions list # list the deployed versions
```

`npx` uses the wrangler version in this project's `node_modules/`, not a global one.

## Layout

| Path | In git | Content |
| --- | --- | --- |
| `cwm` | yes | The tool |
| `setup-env.sh` | yes | Setup script that writes the credentials file |
| `package.json`, `package-lock.json` | yes | Pinned wrangler version |
| `templates/worker/` | yes | Starting project for each new Worker (`wrangler.jsonc`, `src/index.js`) |
| `workers/<name>/` | **no** | One wrangler project per Worker (local data) |
| `.env/` | **no** | Credentials |
| `node_modules/` | **no** | Installed wrangler |

## License

BSD 3-Clause. See [LICENSE](LICENSE).

This project is provided as is, without support or maintenance.
