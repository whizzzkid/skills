---
class: one-off
---

# Rails request specs: negotiate MIME with `as:`, not `format:`

**Scenario** — A Rails request spec exercises a non-default response MIME
(`turbo_stream`, `json`) and needs to drive content negotiation.

**Symptom** — `get path, params: {...}, format: :turbo_stream` raises
`ArgumentError: unknown keyword: :format`. `format:` is a routing/URL param, not a
keyword of the request-spec `get`/`post`/`process` helpers.

**Fix** — Use `as: :turbo_stream` / `as: :json` (sets both `CONTENT_TYPE` and
`Accept`), or an explicit `headers: { 'Accept' => '…' }`. Assert the negotiated
type with `response.media_type == Mime[:turbo_stream]`.

**Why not promoted** — Verbatim recipe tied to one framework's RSpec request-spec
helpers; no generalizable principle beyond the Rails-specific keyword.
