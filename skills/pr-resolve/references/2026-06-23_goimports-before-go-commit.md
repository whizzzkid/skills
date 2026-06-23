---
class: principle
skill: wk-pr-resolve
date: 2026-06-23
---

**Rule**

After editing any Go file in Step 6, run `goimports -local <module> -l <file>`
before staging (`-w` to fix, then re-verify). Do not rely on `go test` alone.

**Why**

`go test` validates compilation and correctness but not import grouping
(stdlib / external / internal). A new import in the wrong group passes local
tests, then fails the CI Go-format gate — a wasted CI cycle.

**Where**

Step 6 "For each fix" verify step (item 2).
