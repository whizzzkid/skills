# Shell-Script Structure & Guard Tests

Part of Phase 3 (Test) — apply when testing shell scripts. Relocated from
`SKILL.md` to keep the body under the size ceiling; relocation does not lower
priority.

## Structure tests

- Anchor awk end-ranges to full lines.
- Use two-stage awk when duplicate branch labels exist.
- Use `! grep -q 'pattern'` for negative assertions; `grep -qv` is a false-positive trap.
- Before range-based assertions, scan for string literals containing the end-range keyword and duplicate branch labels.

## Behavioral guard tests

Behavioral guard tests must reach the guarded branch. `[[ -f "$x" ]]` follows
symlinks → point symlink-escape tests at `/etc/passwd` and confirm the test
fails when the guard is removed.
