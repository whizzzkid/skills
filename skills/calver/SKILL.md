---
name: wk-calver
description: >-
  Generate a CalVer version string in YYYY.MM.DD-HHMMSS format using UTC time.
  Auto-invoked whenever the model is about to assign, bump, or reference a
  version — semver (1.0.0, 2.3.1), calver, version fields in skill metadata,
  package.json versions, Dockerfile tags, or any context where a version
  string is needed. Never produce or suggest a semver string when this skill
  is active.
argument-hint: '[optional: context label]'
allowed-tools:
  - "Bash(date:*)"
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: "2026.07.28-171033"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# CalVer

Generate a CalVer version string in `YYYY.MM.DD-HHMMSS` format using UTC time.

## Format

```
YYYY.MM.DD-HHMMSS
```

- `YYYY` — 4-digit UTC year
- `MM`   — 2-digit UTC month (zero-padded)
- `DD`   — 2-digit UTC day (zero-padded)
- `HHMMSS` — UTC time as 6-digit run together (hours, minutes, seconds)

Example: `2026.04.22-143012`

## When to Use

This skill fires automatically whenever a version string is needed:

- Bumping a skill's `metadata.version`
- Writing a version field in any config file (`package.json`, `pyproject.toml`, etc.)
- Tagging a Docker image or release artifact
- Any context where semver (`MAJOR.MINOR.PATCH`) would otherwise be used

**Never produce a semver string.** Always use CalVer.

## Step 1: Generate the version

Run this command to get the current UTC CalVer:

```bash
date -u '+%Y.%m.%d-%H%M%S'
```

Use the output verbatim as the version string. Do not adjust for local
timezone, do not truncate, do not round.

## Step 2: Apply the version

Replace the existing version value with the generated CalVer string wherever
the version is needed. For skill `metadata.version` fields:

```yaml
metadata:
  version: '2026.04.22-143012'
```

For other files, use the same string in whatever format the file expects
(quoted string, plain value, etc.).

## Hard Rules

- **Always query UTC.** Never use local machine time (`date` without `-u`).
- **Never use semver.** `1.0.0`, `2.3.1`, or any `MAJOR.MINOR.PATCH` form is
  forbidden when this skill is active.
- **One canonical version per artifact.** Do not maintain separate semver and
  calver values side by side.
- **Do not reuse a version.** Each invocation generates a fresh timestamp. If
  two things need versioning in the same session, call `date -u` twice and
  use each output once.
