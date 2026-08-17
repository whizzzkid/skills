---
name: wk-cloudsmith
description: Working with Cloudsmith package registry — upload, query, and auth patterns
model: sonnet
effort: low
model-invocable: true
license: MIT
group: tools
metadata:
  author: whizzzkid
  version: "2026.08.17-204640"
  model:
    openai: gpt-5.6-terra
---

# Cloudsmith

Patterns for publishing and querying packages in the Cloudsmith raw package registry.

## Raw package upload — two-step process

Cloudsmith raw uploads are **not** a single multipart POST. They require two separate calls:

### Step 1: PUT file bytes
```bash
# Returns JSON: {"identifier": "<single-use-token>"}
curl -sS --fail-with-body \
  -X PUT \
  -H "X-Api-Key: $CLOUDSMITH_API_KEY" \
  -H "Content-Type: application/octet-stream" \
  --data-binary "@/path/to/binary" \
  -o response.json \
  -w '%{http_code}' \
  "https://upload.cloudsmith.io/{ORG}/{REPO}/{package-name}"

identifier=$(jq -r '.identifier' response.json)
```

### Step 2: POST metadata
```bash
# Creates the package entry with name, version, tags
curl -sS --fail-with-body \
  -X POST \
  -H "X-Api-Key: $CLOUDSMITH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"package_file\":\"$identifier\",\"filename\":\"$name\",\"name\":\"$name\",\"version\":\"$version\",\"tags\":\"$tags\"}" \
  "https://api.cloudsmith.io/v1/packages/{ORG}/{REPO}/upload/raw/"
```

**Common mistake:** sending a single multipart `-F` POST to `upload.cloudsmith.io/v1/packages/.../raw/` returns 404 — that path does not exist.

## Auth header

The API key header is `X-Api-Key`, NOT `Authorization: Bearer`:

```bash
# Correct
-H "X-Api-Key: $CLOUDSMITH_API_KEY"

# Wrong (returns 401 or 403)
-H "Authorization: Bearer $CLOUDSMITH_API_KEY"
```

## Buildkite cloudsmith-auth plugin

The `cloudsmith-auth-buildkite-plugin` ($GITHUB_ORG fork, mode: publish) exchanges a Buildkite OIDC token for a short-lived API key. It injects these env vars:

- `CLOUDSMITH_API_KEY` — the minted publish token
- `CLOUDSMITH_REPO` — the repository slug (e.g. `{ORG}`)
- `CLOUDSMITH_ACCOUNT` — NOT injected by the plugin; set separately or hardcode

Plugin YAML reference:
```yaml
plugins:
  - "ssh://git@github.com/$GITHUB_ORG/cloudsmith-auth-buildkite-plugin.git#v2.2.0":
      mode: publish
```

In `Buildkite::Builder` Ruby DSL:
```ruby
plugin :cloudsmith_auth, mode: "publish"
plugin :docker_compose, run: context[:runner], env: ["CLOUDSMITH_ACCOUNT", "CLOUDSMITH_API_KEY", "CLOUDSMITH_REPO"]
```

**CLOUDSMITH_REPO forwarding:** the plugin injects `CLOUDSMITH_REPO` into the agent environment, but docker_compose only forwards env vars listed in its `env:` array. If `CLOUDSMITH_REPO` is absent from that array, the container will not receive it and the script falls back to the default.

## Bundler credentials for a Cloudsmith gem source

A vendor-named variable like `CLOUDSMITH_API_KEY` is invisible to Bundler. Bundler
reads credentials per gem-source **hostname**, so the variable name is derived, not
chosen.

- Config key = the source hostname; periods become two underscores, uppercased and
  `BUNDLE_`-prefixed. Host `dl.cloudsmith.io` → `BUNDLE_DL__CLOUDSMITH__IO`.
- Value is `USERNAME:PASSWORD`; Cloudsmith's username is the literal `token`:

  ```bash
  export BUNDLE_DL__CLOUDSMITH__IO="token:$CLOUDSMITH_API_KEY"
  ```

- Derive the name from the `source` host in the Gemfile, never from memory — a
  vanity or org-specific host yields a different variable.
- A project's own provisioning script exports this; a **manually started**
  container does not inherit it, so `bundle install` 401s there while the
  project's tooling works. Read that script for the exact name rather than
  reconstructing it.

## Org and repo naming

For this project:
- **Org (account):** `{ORG}`
- **Repo:** `{ORG}` (the repository within the org is also named `{ORG}`)
- Full address: `{ORG}/{ORG}`

The upload URL for a binary named `{package-name}-linux-x64` is:
```
https://upload.cloudsmith.io/{ORG}/{ORG}/{package-name}-linux-x64
```

The metadata API URL is:
```
https://api.cloudsmith.io/v1/packages/{ORG}/{ORG}/upload/raw/
```

## Querying packages (for tier-resolver download)

```bash
# List packages matching a name query
curl -sS \
  -H "X-Api-Key: $CLOUDSMITH_API_KEY" \
  "https://api.cloudsmith.io/v1/packages/{ORG}/{ORG}/?query=name:{pkg-name}&page_size=1"

# CDN download URL is in the response as .cdn_url
# CDN download requires basic auth (not X-Api-Key):
curl -u "$CLOUDSMITH_USER:$CLOUDSMITH_API_KEY" -fsSL -o binary "$cdn_url"
```

## DRY_RUN pattern

When `CLOUDSMITH_API_KEY` is absent, skip publish and exit 0 (for local runs):

```bash
if [[ -z "$CLOUDSMITH_API_KEY" ]]; then
  echo "DRY RUN — CLOUDSMITH_API_KEY not set, skipping publish"
  exit 0
fi
```

## Error body capture

Use `--fail-with-body` (curl 7.76+) instead of `-f`/`--fail` so the response body is written to the `-o` file on 4xx/5xx (plain `--fail` exits before writing the body):

```bash
curl -sS --fail-with-body \
  -o "$response_file" \
  -w '%{http_code}' \
  ...
```

## Tags

Tags is a **comma-separated string**, not an array:
```json
{"tags": "{package-name},stable"}  // correct
{"tags": ["{package-name}", "stable"]}  // wrong — API rejects arrays
```
