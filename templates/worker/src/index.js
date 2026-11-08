// Default Worker code. `./cwm create <name>` copies it to workers/<name>/src/index.js.
// workers/ is gitignored. Edit the copy, then run `./cwm deploy <name>` to deploy it.

export default {
  async fetch(request) {
    const cf = request.cf ?? {};
    return Response.json({
      message: "Hello from a Cloudflare Worker",
      url: request.url,
      colo: cf.colo ?? null,
      country: cf.country ?? null,
      time: new Date().toISOString(),
    });
  },
};
