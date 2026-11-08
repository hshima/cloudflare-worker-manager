# cloudflare-worker-manager

`cwm` is a small bash tool that creates, deletes and recreates Cloudflare Workers through the Cloudflare API.
It needs only `curl` and `jq`. It does not need Node.js or `wrangler`.

## Setup

1. Create a Cloudflare API token with these permissions:

   | Scope | Resource | Access | Why |
   | --- | --- | --- | --- |
   | Account | Workers Scripts | Edit | **Required.** `cwm` uploads, deletes and lists Workers, and reads the `workers.dev` subdomain. |
   | Account | Account Settings | Read | Optional. Lets tools read account details. `cwm` does not use it now. |
   | Account | Workers AI | Edit | Optional. For Workers AI. `cwm` does not use it now. |

2. Run the setup script. It asks for the account ID and the token, checks them with the
   Cloudflare API, and writes `.env/cloudflare-claude-worker-manager.sh` (mode 600):
   ```bash
   ./setup-env.sh
   ```

## Usage

```bash
./cwm create   my-api   # copy the template to workers/my-api/index.js (first time), then deploy
./cwm recreate my-api   # delete the Worker, then deploy it again
./cwm delete   my-api   # delete the Worker on Cloudflare; local code stays
./cwm list              # list the Workers in the account
./cwm url      my-api   # print https://my-api.<subdomain>.workers.dev
```

To change a Worker, edit `workers/<name>/index.js` and run `./cwm create <name>` again.

## Layout

| Path | In git | Content |
| --- | --- | --- |
| `cwm` | yes | The tool |
| `templates/worker/index.js` | yes | Starting code for each new Worker |
| `setup-env.sh` | yes | Setup script that writes the credentials file |
| `workers/<name>/` | **no** | Code of each Worker (local data) |
| `.env/` | **no** | Credentials |

## License

BSD 3-Clause. See [LICENSE](LICENSE).

This project is provided as is, without support or maintenance.
