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
  version: "2026.10.09-184159"
  model:
    openai: gpt-5.6-terra
---

# Cloudsmith

## Raw package upload — two calls, never one multipart POST

A single multipart `-F` POST to `upload.cloudsmith.io/v1/packages/.../raw/` returns 404: that path does not exist.

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

- Tags: a **comma-separated string**, never an array (`{"tags": "{package-name},stable"}`); the API rejects arrays.
- Error bodies: use `--fail-with-body` (curl 7.76+), never `-f`/`--fail`; plain `--fail` exits before writing the body
  to the `-o` file on 4xx/5xx.

## Auth header

Use `-H "X-Api-Key: $CLOUDSMITH_API_KEY"`, NOT `Authorization: Bearer` (returns 401 or 403).

## Buildkite cloudsmith-auth plugin

`cloudsmith-auth-buildkite-plugin` ($GITHUB_ORG fork, mode: publish) exchanges a Buildkite OIDC token for a short-lived
API key and injects `CLOUDSMITH_API_KEY` (minted publish token) and `CLOUDSMITH_REPO` (repo slug, e.g. `{ORG}`).
`CLOUDSMITH_ACCOUNT` is NOT injected: set it separately or hardcode.

```yaml
plugins:
  - "ssh://git@github.com/$GITHUB_ORG/cloudsmith-auth-buildkite-plugin.git#v2.2.0":
      mode: publish
```

`Buildkite::Builder` Ruby DSL:
```ruby
plugin :cloudsmith_auth, mode: "publish"
plugin :docker_compose, run: context[:runner], env: ["CLOUDSMITH_ACCOUNT", "CLOUDSMITH_API_KEY", "CLOUDSMITH_REPO"]
```

List `CLOUDSMITH_REPO` in docker_compose's `env:` array: docker_compose forwards only listed vars, so without it the
container never receives it and the script falls back to the default.

## Bundler credentials for a Cloudsmith gem source

Bundler ignores `CLOUDSMITH_API_KEY`; it reads credentials per gem-source **hostname**, so derive the variable name.

- Name: the source hostname, periods → two underscores, uppercased, `BUNDLE_`-prefixed (`dl.cloudsmith.io` →
  `BUNDLE_DL__CLOUDSMITH__IO`). Value: `USERNAME:PASSWORD`, username the literal `token`:

  ```bash
  export BUNDLE_DL__CLOUDSMITH__IO="token:$CLOUDSMITH_API_KEY"
  ```

- Derive the name from the Gemfile `source` host, never from memory: a vanity or org-specific host yields a different
  variable.
- A **manually started** container does not inherit the project's provisioning export, so `bundle install` 401s there
  while project tooling works: read that script for the exact name rather than reconstructing it.

## Org and repo naming

This project: org (account) `{ORG}`, repo `{ORG}`, full address `{ORG}/{ORG}`.

- Upload URL for `{package-name}-linux-x64`: `https://upload.cloudsmith.io/{ORG}/{ORG}/{package-name}-linux-x64`
- Metadata API URL: `https://api.cloudsmith.io/v1/packages/{ORG}/{ORG}/upload/raw/`

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

When `CLOUDSMITH_API_KEY` is absent, skip publish and exit 0 (local runs):

```bash
if [[ -z "$CLOUDSMITH_API_KEY" ]]; then
  echo "DRY RUN — CLOUDSMITH_API_KEY not set, skipping publish"
  exit 0
fi
```
