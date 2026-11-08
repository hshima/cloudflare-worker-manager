# cloudflare-worker-manager

`cwm` is a small bash tool that creates, deletes and recreates Cloudflare Workers through the Cloudflare API.
It needs only `curl` and `jq`. It does not need Node.js or `wrangler`.

## Setup

1. Create a Cloudflare API token with the permission **Account > Workers Scripts > Edit**.
2. Copy the example credentials file and fill in the values:
   ```bash
   mkdir -p .env
   cp env.example.sh .env/cloudflare-claude-worker-manager.sh
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
| `env.example.sh` | yes | Example credentials file |
| `workers/<name>/` | **no** | Code of each Worker (local data) |
| `.env/` | **no** | Credentials |
