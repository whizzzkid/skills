---
skill: wk-testing-skeleton
date: 2026-07-21
type: correction
severity: low
---

Rails request-spec `get`/`post` selects a non-default response MIME with `as:`, never `format:`.

**What happened:** A request spec exercising a `turbo_stream` endpoint used `get path, params: {...}, format: :turbo_stream`, which raised `ArgumentError: unknown keyword: :format`. Switching to `as: :turbo_stream` (or setting an explicit `headers: { 'Accept' => '...' }`) fixed it.

**Root cause:** `format:` is a valid *routing/URL* param but not a keyword of the request-spec `get`/`post`/`process` helpers. `as:` is the supported keyword; it sets both the `CONTENT_TYPE` and `Accept` for the simulated request.

**Suggested fix:** In request specs, drive content negotiation with `as: :turbo_stream` / `as: :json` (or an explicit `Accept` header), never a `format:` keyword. Assert the negotiated type via `response.media_type == Mime[:turbo_stream]`.
