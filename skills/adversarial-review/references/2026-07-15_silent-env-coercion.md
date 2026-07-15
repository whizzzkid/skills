---
class: principle
---

**Rule** — When reviewing config/env parsing, grep `.to_i` / `parseInt` / `atoi`
on external input and ask "what does 0 mean here?" If `0` is load-bearing
(disable, unlimited, kill-switch), require strict parsing that distinguishes
malformed from zero.

**Why** — `String#to_i` (and `parseInt`/`atoi`) never raise: a fully non-numeric
string returns `0`. When `0` is a meaningful boundary, a typo silently turns the
feature off — no exception, no log, invisible operator misconfiguration.

**Where** — wk-adversarial-review extended sweep catalog row 2.76. The retro's
tautological-regression-test catch was already-covered (category "Test quality:
tautology" + rows 2.69) with positive-steering evidence, so not folded.
