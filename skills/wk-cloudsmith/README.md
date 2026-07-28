# wk-cloudsmith

Working with the Cloudsmith package registry — upload, query, and auth patterns for raw packages.

**Version:** `2026.07.28-171113`

## Invocation

| Mode | Trigger |
|------|---------|
| Model-invocable | Automatic when working with Cloudsmith upload/query operations |

## Key Patterns

- **Two-step raw upload**: PUT file bytes to `upload.cloudsmith.io` → POST metadata to `api.cloudsmith.io`. Single multipart POST returns 404.
- **Auth header**: `X-Api-Key: $CLOUDSMITH_API_KEY` — not `Authorization: Bearer`.
- **Buildkite plugin**: `cloudsmith-auth-buildkite-plugin` injects `CLOUDSMITH_API_KEY` and `CLOUDSMITH_REPO`; `CLOUDSMITH_ACCOUNT` is not injected — set separately.
- **Error body capture**: use `--fail-with-body` (curl 7.76+), not `-f`, so the response body is written on 4xx/5xx.
- **DRY_RUN guard**: when `CLOUDSMITH_API_KEY` is absent, skip and exit 0.
- **Tags**: comma-separated string, not an array.

## Integration Points

- [wk-curl](../curl/README.md) — curl invocation patterns apply here; `--fail-with-body` is enforced
- [wk-buildkite](../buildkite/README.md) — Buildkite plugin wiring for OIDC-based auth
