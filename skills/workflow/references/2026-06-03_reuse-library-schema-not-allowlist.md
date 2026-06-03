---
class: principle
---

- **Rule:** Before hardcoding an allowlist of an external API's field names, check whether the client library's types already encode it (struct tags, generated enums); prefer strict decoding (`DisallowUnknownFields` / schema `forbid`) so the type becomes the allowlist.
- **Why:** A parallel hand-maintained list silently drifts every time the upstream API adds or removes a field — a maintenance trap.
- **Where:** New "External-API field validation" subsection under Phase 2 Code Standards.
