# Skills Group Restructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize 31 skills from a flat `skills/<name>/` layout into four logical groups (`rituals/`, `pull-request/`, `tools/`, `workflows/`) and mirror that structure in `learnings/skills/`.

**Architecture:** Each skill moves from `skills/<name>/SKILL.md` to `skills/<group>/<name>/SKILL.md`. The `name:` frontmatter field and invocation syntax (`/wk-<name>`) are unchanged — `npx skills` uses the `name:` field, not the directory path. The `wk-learn` argument in every `Post-Completion` section is updated to `<group>/<name>` so learnings land in the right nested path. Existing learnings files are migrated to match.

**Tech Stack:** `git mv`, `sed`/`Edit` for SKILL.md edits, `npx skills add .` for registry refresh

---

## Group Taxonomy

```
skills/
├── _template/          (stays at root — internal, no group)
├── rituals/            (time-bounded routines: daily bookends + reviews)
│   ├── cal/
│   ├── goodevening/
│   ├── goodmorning/
│   ├── retro/
│   └── self-perf/
├── pull-request/       (full PR lifecycle)
│   ├── pr/
│   ├── pr-break/
│   ├── pr-resolve/
│   ├── pr-review/
│   ├── pr-update/
│   └── self-review/
├── tools/              (external tool integrations)
│   ├── buildkite/
│   ├── datadog/
│   ├── devcontainer/
│   ├── docker/
│   ├── gh/
│   ├── jira/
│   └── mise/
└── workflows/          (development process: code → commit → PR)
    ├── calver/
    ├── commit/
    ├── concise/
    ├── docs/
    ├── format/
    ├── learn/
    ├── markdown/
    ├── refactor/
    ├── sharpen/
    ├── skill/
    ├── testing-skeleton/
    ├── workflow/
    └── worktree-cleanup/
```

## What Does NOT Change

- `name:` frontmatter in every SKILL.md (invocation stays `/wk-buildkite` etc.)
- Cross-skill references (`wk-commit`, `wk-pr`, `wk-learn` in skill bodies) — these use `name:`, not path
- `wk-learn` logic — already does `mkdir -p "$WK_SKILLS_HOME/learnings/skills/$SKILL_NAME"`, so passing `tools/buildkite` just creates the right subpath
- `wk-sharpen` learnings scan — already uses recursive `find "$WK_SKILLS_HOME/learnings/skills" -name "*.md"`, handles nesting fine

## What Changes

| Location | Change |
|---|---|
| `skills/<name>/` | Moved to `skills/<group>/<name>/` (git mv) |
| Post-Completion `wk-learn <name>` | Updated to `wk-learn <group>/<name>` in all 31 SKILL.md files |
| `learnings/skills/<name>/` | Moved to `learnings/skills/<group>/<name>/` |
| `learnings/skills/wk-workflow/` | Merged into `learnings/skills/workflows/workflow/` |
| `AGENTS.md` skills table + path doc | Updated to reflect group paths |
| `README.md` skills table | Updated to reflect group paths |
| `skills/skill/SKILL.md` | Guard/scaffold steps updated for `<group>/<name>` format |
| `skills/learn/SKILL.md` | argument-hint updated to `<group>/<name>` format |

---

## Task 1: Verify npx skills supports nested directories

**Files:**
- No file changes — read-only test

- [ ] **Step 1: Create a temp nested skill to verify scanner**

```bash
mkdir -p "$WK_SKILLS_HOME/skills/_test-group/_test-nested"
cat > "$WK_SKILLS_HOME/skills/_test-group/_test-nested/SKILL.md" <<'EOF'
---
name: wk-test-nested-verify
description: Temporary skill to verify npx skills handles nested dirs.
metadata:
  version: 2026.01.01-000000
  internal: true
---
# Test
EOF
```

- [ ] **Step 2: Run install and check**

```bash
cd "$WK_SKILLS_HOME" && npx skills add . -g -y -a=claude 2>&1 | tail -3
npx skills list -a=claude 2>/dev/null | grep "wk-test-nested-verify"
```

Expected: `wk-test-nested-verify` appears in the list.

- [ ] **Step 3: Remove temp skill**

```bash
rm -rf "$WK_SKILLS_HOME/skills/_test-group"
cd "$WK_SKILLS_HOME" && npx skills add . -g -y -a=claude 2>&1 | tail -3
```

- [ ] **Step 4: Confirm removal**

```bash
npx skills list -a=claude 2>/dev/null | grep "wk-test-nested-verify"
```

Expected: no output. If nested skills work, proceed. If not, STOP and report.

---

## Task 2: Move skill directories (git mv)

**Files:**
- Move: all 31 skill dirs into their groups (no file content changes)

- [ ] **Step 1: Create group directories**

```bash
mkdir -p "$WK_SKILLS_HOME/skills/rituals"
mkdir -p "$WK_SKILLS_HOME/skills/pull-request"
mkdir -p "$WK_SKILLS_HOME/skills/tools"
mkdir -p "$WK_SKILLS_HOME/skills/workflows"
```

- [ ] **Step 2: Move rituals (5 skills)**

```bash
cd "$WK_SKILLS_HOME"
git mv skills/cal             skills/rituals/cal
git mv skills/goodevening     skills/rituals/goodevening
git mv skills/goodmorning     skills/rituals/goodmorning
git mv skills/retro           skills/rituals/retro
git mv skills/self-perf       skills/rituals/self-perf
```

- [ ] **Step 3: Move pull-request (6 skills)**

```bash
cd "$WK_SKILLS_HOME"
git mv skills/pr              skills/pull-request/pr
git mv skills/pr-break        skills/pull-request/pr-break
git mv skills/pr-resolve      skills/pull-request/pr-resolve
git mv skills/pr-review       skills/pull-request/pr-review
git mv skills/pr-update       skills/pull-request/pr-update
git mv skills/self-review     skills/pull-request/self-review
```

- [ ] **Step 4: Move tools (7 skills)**

```bash
cd "$WK_SKILLS_HOME"
git mv skills/buildkite       skills/tools/buildkite
git mv skills/datadog         skills/tools/datadog
git mv skills/devcontainer    skills/tools/devcontainer
git mv skills/docker          skills/tools/docker
git mv skills/gh              skills/tools/gh
git mv skills/jira            skills/tools/jira
git mv skills/mise            skills/tools/mise
```

- [ ] **Step 5: Move workflows (13 skills)**

```bash
cd "$WK_SKILLS_HOME"
git mv skills/calver          skills/workflows/calver
git mv skills/commit          skills/workflows/commit
git mv skills/concise         skills/workflows/concise
git mv skills/docs            skills/workflows/docs
git mv skills/format          skills/workflows/format
git mv skills/learn           skills/workflows/learn
git mv skills/markdown        skills/workflows/markdown
git mv skills/refactor        skills/workflows/refactor
git mv skills/sharpen         skills/workflows/sharpen
git mv skills/skill           skills/workflows/skill
git mv skills/testing-skeleton skills/workflows/testing-skeleton
git mv skills/workflow        skills/workflows/workflow
git mv skills/worktree-cleanup skills/workflows/worktree-cleanup
```

- [ ] **Step 6: Verify git status looks right**

```bash
cd "$WK_SKILLS_HOME" && git status --short | grep "^R" | wc -l
```

Expected: `31` renamed entries. Spot-check a few:

```bash
git status --short | grep "skills/tools/buildkite"
git status --short | grep "skills/pull-request/pr-resolve"
git status --short | grep "skills/rituals/goodmorning"
```

- [ ] **Step 7: Reinstall skills and verify all 31 resolve**

```bash
cd "$WK_SKILLS_HOME" && npx skills add . -g -y -a=claude 2>&1 | tail -3
npx skills list -a=claude 2>/dev/null | grep "^wk-" | wc -l
```

Expected: same count as before (≥31). Spot-check:

```bash
npx skills list -a=claude 2>/dev/null | grep -E "wk-buildkite|wk-goodmorning|wk-pr-resolve|wk-commit"
```

- [ ] **Step 8: Commit the moves**

```bash
cd "$WK_SKILLS_HOME" && git add -A skills/
git commit -m "$(cat <<'EOF'
refactor(skills): ♻️ group skills into rituals/pull-request/tools/workflows

Moves 31 skills from flat skills/<name>/ into four logical groups.
name: fields and invocation syntax unchanged — only directory layout.
EOF
)"
```

---

## Task 3: Update wk-learn argument in all Post-Completion sections

Every SKILL.md has a Post-Completion section ending with `wk-learn <short-name>`. Update each to `wk-learn <group>/<name>`.

**Files:**
- Modify: all 31 `skills/<group>/<name>/SKILL.md` Post-Completion sections

The mapping is:

| Old | New |
|---|---|
| `wk-learn cal` | `wk-learn rituals/cal` |
| `wk-learn goodevening` | `wk-learn rituals/goodevening` |
| `wk-learn goodmorning` | `wk-learn rituals/goodmorning` |
| `wk-learn retro` | `wk-learn rituals/retro` |
| `wk-learn self-perf` | `wk-learn rituals/self-perf` |
| `wk-learn pr` | `wk-learn pull-request/pr` |
| `wk-learn pr-break` | `wk-learn pull-request/pr-break` |
| `wk-learn pr-resolve` | `wk-learn pull-request/pr-resolve` |
| `wk-learn pr-review` | `wk-learn pull-request/pr-review` |
| `wk-learn pr-update` | `wk-learn pull-request/pr-update` |
| `wk-learn self-review` | `wk-learn pull-request/self-review` |
| `wk-learn buildkite` | `wk-learn tools/buildkite` |
| `wk-learn datadog` | `wk-learn tools/datadog` |
| `wk-learn devcontainer` | `wk-learn tools/devcontainer` |
| `wk-learn docker` | `wk-learn tools/docker` |
| `wk-learn gh` | `wk-learn tools/gh` |
| `wk-learn jira` | `wk-learn tools/jira` |
| `wk-learn mise` | `wk-learn tools/mise` |
| `wk-learn calver` | `wk-learn workflows/calver` |
| `wk-learn commit` | `wk-learn workflows/commit` |
| `wk-learn concise` | `wk-learn workflows/concise` |
| `wk-learn docs` | `wk-learn workflows/docs` |
| `wk-learn format` | `wk-learn workflows/format` |
| `wk-learn learn` | `wk-learn workflows/learn` |
| `wk-learn markdown` | `wk-learn workflows/markdown` |
| `wk-learn refactor` | `wk-learn workflows/refactor` |
| `wk-learn sharpen` | `wk-learn workflows/sharpen` |
| `wk-learn skill` | `wk-learn workflows/skill` |
| `wk-learn testing-skeleton` | `wk-learn workflows/testing-skeleton` |
| `wk-learn workflow` | `wk-learn workflows/workflow` |
| `wk-learn worktree-cleanup` | `wk-learn workflows/worktree-cleanup` |

- [ ] **Step 1: Apply all Post-Completion updates via sed**

```bash
cd "$WK_SKILLS_HOME"

# rituals
for skill in cal goodevening goodmorning retro self-perf; do
  sed -i '' "s/wk-learn $skill$/wk-learn rituals\/$skill/" "skills/rituals/$skill/SKILL.md"
done

# pull-request
for skill in pr pr-break pr-resolve pr-review pr-update self-review; do
  sed -i '' "s/wk-learn $skill$/wk-learn pull-request\/$skill/" "skills/pull-request/$skill/SKILL.md"
done

# tools
for skill in buildkite datadog devcontainer docker gh jira mise; do
  sed -i '' "s/wk-learn $skill$/wk-learn tools\/$skill/" "skills/tools/$skill/SKILL.md"
done

# workflows
for skill in calver commit concise docs format learn markdown refactor sharpen skill testing-skeleton workflow worktree-cleanup; do
  sed -i '' "s/wk-learn $skill$/wk-learn workflows\/$skill/" "skills/workflows/$skill/SKILL.md"
done
```

- [ ] **Step 2: Verify every Post-Completion section was updated**

```bash
cd "$WK_SKILLS_HOME"
# Should find 31 matches with group-qualified paths
grep -r "wk-learn " skills/*/*/SKILL.md | grep -v "wk-learn scan\|wk-learn <" | wc -l
# Should find 0 bare (non-group-qualified) wk-learn calls in Post-Completion
grep -r "wk-learn " skills/*/*/SKILL.md | grep "Post-Completion" 
# All remaining bare wk-learn refs should be in skill body examples (not Post-Completion)
grep -rn "e\.g\., \`wk-learn [a-z]" skills/*/*/SKILL.md | head -10
```

- [ ] **Step 3: Also update the example in wk-learn's own argument-hint**

Edit `skills/workflows/learn/SKILL.md` frontmatter:

```yaml
# Change:
argument-hint: '<skill-name> | scan  (e.g., pr-review, commit, workflow, scan)'
# To:
argument-hint: '<group>/<skill-name> | scan  (e.g., pull-request/pr-review, workflows/commit, scan)'
```

Also update the body example text in wk-learn that says:
```
(e.g., `wk-learn pr-review`)
```
→ 
```
(e.g., `wk-learn pull-request/pr-review`)
```

And update the path documentation line:
```
`$WK_SKILLS_HOME/learnings/skills/<skill-name>/<YYYY-MM-DD>_<slug>.md`
```
→
```
`$WK_SKILLS_HOME/learnings/skills/<group>/<skill-name>/<YYYY-MM-DD>_<slug>.md`
```

- [ ] **Step 4: Commit**

```bash
cd "$WK_SKILLS_HOME" && git add -A skills/
git commit -m "$(cat <<'EOF'
chore(skills): 🔧 update wk-learn paths to group-qualified format

Updates Post-Completion wk-learn calls in all 31 skills to use
<group>/<name> format. Updates wk-learn argument-hint and examples.
EOF
)"
```

---

## Task 4: Migrate learnings directories

Move existing learnings to mirror the new group structure. The `wk-workflow/` anomaly (should be `workflow/`) gets cleaned up here too — merge into `workflows/workflow/`.

**Files:**
- Move: `learnings/skills/<name>/` → `learnings/skills/<group>/<name>/`
- Merge: `learnings/skills/wk-workflow/` + `learnings/skills/workflow/` → `learnings/skills/workflows/workflow/`

- [ ] **Step 1: Create group directories in learnings**

```bash
mkdir -p "$WK_SKILLS_HOME/learnings/skills/rituals"
mkdir -p "$WK_SKILLS_HOME/learnings/skills/pull-request"
mkdir -p "$WK_SKILLS_HOME/learnings/skills/tools"
mkdir -p "$WK_SKILLS_HOME/learnings/skills/workflows"
```

- [ ] **Step 2: Move rituals learnings**

```bash
cd "$WK_SKILLS_HOME/learnings/skills"
# Only move dirs that exist
for skill in goodevening goodmorning retro; do
  [ -d "$skill" ] && git mv "$skill" "rituals/$skill"
done
# cal, self-perf have no learnings yet — nothing to move
```

- [ ] **Step 3: Move pull-request learnings**

```bash
cd "$WK_SKILLS_HOME/learnings/skills"
for skill in pr pr-break pr-resolve pr-review self-review; do
  [ -d "$skill" ] && git mv "$skill" "pull-request/$skill"
done
# pr-update has no learnings yet
```

- [ ] **Step 4: Move tools learnings**

```bash
cd "$WK_SKILLS_HOME/learnings/skills"
for skill in buildkite gh jira; do
  [ -d "$skill" ] && git mv "$skill" "tools/$skill"
done
# datadog, devcontainer, docker, mise have no learnings yet
```

- [ ] **Step 5: Move workflows learnings + merge wk-workflow anomaly**

```bash
cd "$WK_SKILLS_HOME/learnings/skills"
for skill in commit refactor sharpen worktree-cleanup; do
  [ -d "$skill" ] && git mv "$skill" "workflows/$skill"
done

# Move workflow/ into workflows/workflow/
[ -d "workflow" ] && git mv "workflow" "workflows/workflow"

# The wk-workflow/ dir is untracked (git status showed ?? learnings/skills/wk-workflow/)
# Move its content into the new workflows/workflow/ dir manually
if [ -d "wk-workflow" ]; then
  mv wk-workflow/* workflows/workflow/ 2>/dev/null || true
  rmdir wk-workflow
fi
```

- [ ] **Step 6: Verify no orphaned learnings remain at old paths**

```bash
cd "$WK_SKILLS_HOME/learnings/skills"
# Should only show the 4 group dirs
ls -d */ 2>/dev/null
```

Expected output:
```
pull-request/  rituals/  tools/  workflows/
```

- [ ] **Step 7: Spot-check a few learnings are accessible**

```bash
ls "$WK_SKILLS_HOME/learnings/skills/pull-request/pr-resolve/" | head -3
ls "$WK_SKILLS_HOME/learnings/skills/tools/buildkite/" | head -3
ls "$WK_SKILLS_HOME/learnings/skills/workflows/workflow/" | head -3
```

- [ ] **Step 8: Commit learnings migration**

```bash
cd "$WK_SKILLS_HOME" && git add -A learnings/
git commit -m "$(cat <<'EOF'
refactor(learnings): ♻️ mirror skill group structure in learnings/skills/

Moves existing learnings dirs into group subdirs matching skills/ layout.
Merges wk-workflow/ anomaly into workflows/workflow/.
EOF
)"
```

---

## Task 5: Update wk-skill scaffold to support groups

`skills/workflows/skill/SKILL.md` currently scaffolds into `skills/<name>/`. Update it to ask for the group and scaffold into `skills/<group>/<name>/`.

**Files:**
- Modify: `skills/workflows/skill/SKILL.md`

- [ ] **Step 1: Update Step 2 (collision guard)**

Find:
```bash
test -d "$WK_SKILLS_HOME/skills/<name>" && echo "EXISTS" || echo "CLEAR"
```

Replace with:
```bash
test -d "$WK_SKILLS_HOME/skills/<group>/<name>" && echo "EXISTS" || echo "CLEAR"
```

And add to Step 2 preamble: prompt the user for the **group** (`rituals`, `pull-request`, `tools`, `workflows`) if not provided as part of the argument.

- [ ] **Step 2: Update Step 6 (scaffold)**

Find:
```bash
mkdir -p "$WK_SKILLS_HOME/skills/<name>"
```
Replace with:
```bash
mkdir -p "$WK_SKILLS_HOME/skills/<group>/<name>"
```

And all three references to path in the scaffold step:
- `Write \`$WK_SKILLS_HOME/skills/<name>/SKILL.md\`` → `Write \`$WK_SKILLS_HOME/skills/<group>/<name>/SKILL.md\``
- `"Scaffold written to \`skills/<name>/SKILL.md\`."` → `"Scaffold written to \`skills/<group>/<name>/SKILL.md\`."`
- Post-Completion example: `wk-learn <name>` → `wk-learn <group>/<name>`

- [ ] **Step 3: Verify the file looks right**

```bash
grep -n "skills/<name>\|skills/<group>" "$WK_SKILLS_HOME/skills/workflows/skill/SKILL.md"
```

Expected: no remaining bare `skills/<name>` references (only `skills/<group>/<name>`).

- [ ] **Step 4: Commit**

```bash
cd "$WK_SKILLS_HOME" && git add skills/workflows/skill/SKILL.md
git commit -m "$(cat <<'EOF'
feat(wk-skill): ✨ prompt for group when scaffolding new skills

Updates collision guard, mkdir, and Post-Completion example to use
<group>/<name> paths matching the new grouped layout.
EOF
)"
```

---

## Task 6: Update AGENTS.md and README.md

Both files have a skills table with hardcoded `skills/<name>/` paths.

**Files:**
- Modify: `AGENTS.md`
- Modify: `README.md`

- [ ] **Step 1: Update AGENTS.md doc line (line 5)**

Find:
```
- Skills live in `skills/<skill-name>/SKILL.md`
```
Replace with:
```
- Skills live in `skills/<group>/<skill-name>/SKILL.md` where group is one of: `rituals`, `pull-request`, `tools`, `workflows`
```

- [ ] **Step 2: Update AGENTS.md skills table**

The table currently has paths like `[buildkite](skills/buildkite/)`. Each must update to `[buildkite](skills/tools/buildkite/)` etc. Full replacement:

```
[buildkite](skills/buildkite/)       → [buildkite](skills/tools/buildkite/)
[commit](skills/commit/)             → [commit](skills/workflows/commit/)
[concise](skills/concise/)           → [concise](skills/workflows/concise/)
[datadog](skills/datadog/)           → [datadog](skills/tools/datadog/)
[docker](skills/docker/)             → [docker](skills/tools/docker/)
[docs](skills/docs/)                 → [docs](skills/workflows/docs/)
[gh](skills/gh/)                     → [gh](skills/tools/gh/)
[goodevening](skills/goodevening/)   → [goodevening](skills/rituals/goodevening/)
[goodmorning](skills/goodmorning/)   → [goodmorning](skills/rituals/goodmorning/)
[mise](skills/mise/)                 → [mise](skills/tools/mise/)
[pr](skills/pr/)                     → [pr](skills/pull-request/pr/)
[pr-resolve](skills/pr-resolve/)     → [pr-resolve](skills/pull-request/pr-resolve/)
[pr-review](skills/pr-review/)       → [pr-review](skills/pull-request/pr-review/)
[retro](skills/retro/)               → [retro](skills/rituals/retro/)
[self-review](skills/self-review/)   → [self-review](skills/pull-request/self-review/)
[sharpen](skills/sharpen/)           → [sharpen](skills/workflows/sharpen/)
[workflow](skills/workflow/)         → [workflow](skills/workflows/workflow/)
[worktree-cleanup](skills/worktree-cleanup/) → [worktree-cleanup](skills/workflows/worktree-cleanup/)
```

(Note: AGENTS.md only lists 18 skills — add any missing ones when updating)

- [ ] **Step 3: Update README.md skills table with same path changes**

Apply the same path substitutions to README.md's skills table.

- [ ] **Step 4: Verify no old paths remain**

```bash
grep -n "skills/buildkite\|skills/goodmorning\|skills/pr-resolve\|skills/commit" \
  "$WK_SKILLS_HOME/AGENTS.md" "$WK_SKILLS_HOME/README.md"
```

Expected: no output.

- [ ] **Step 5: Commit**

```bash
cd "$WK_SKILLS_HOME" && git add AGENTS.md README.md
git commit -m "$(cat <<'EOF'
docs: 📝 update AGENTS.md and README.md for grouped skill paths
EOF
)"
```

---

## Task 7: Final verification

- [ ] **Step 1: Reinstall all skills from scratch**

```bash
cd "$WK_SKILLS_HOME" && npx skills add . -g -y -a=claude 2>&1 | tail -5
```

Expected: `Done!`

- [ ] **Step 2: Verify all 31 wk-* skills are present**

```bash
npx skills list -a=claude 2>/dev/null | grep "^wk-" | sort
```

Expected: 31 skills, all the same names as before (no renames).

- [ ] **Step 3: Check wk-learn path creation**

```bash
# Simulate what wk-learn would do with a group-qualified name
SKILL_NAME="tools/buildkite"
echo "Would write to: $WK_SKILLS_HOME/learnings/skills/$SKILL_NAME/"
ls "$WK_SKILLS_HOME/learnings/skills/tools/buildkite/" | head -3
```

- [ ] **Step 4: Check wk-sharpen learnings scan still finds files**

```bash
find "$WK_SKILLS_HOME/learnings/skills" -name "*.md" ! -name "*.learned.md" -type f | wc -l
find "$WK_SKILLS_HOME/learnings/skills" -name "*.learned.md" -type f | wc -l
```

Both counts should match pre-migration totals (verify no files were lost).

- [ ] **Step 5: Verify directory layout**

```bash
find "$WK_SKILLS_HOME/skills" -maxdepth 2 -type d | sort
```

Expected: only `skills/_template`, `skills/rituals`, `skills/pull-request`, `skills/tools`, `skills/workflows` at depth 1, with skill dirs nested inside each group.

- [ ] **Step 6: Push**

```bash
cd "$WK_SKILLS_HOME" && eval "$(mise activate bash)" && git push
```

---

## Regression Risk Register

| Risk | Mitigation |
|---|---|
| `npx skills` doesn't scan nested dirs | Task 1 verifies this before any moves |
| Skill invocation breaks (`/wk-buildkite` stops working) | `name:` field unchanged; invocation uses name not path |
| wk-learn writes to wrong path | `$SKILL_NAME` is the arg; passing `tools/buildkite` creates the right nested path automatically |
| wk-sharpen misses learnings | Its `find` is already recursive — no change needed |
| Cross-skill references break | All use `wk-name` form (name field) not path — unchanged |
| `.distilled-sources.log` path entries stale | Log entries are already `.learned.md` files; new unprocessed learnings land in new paths; no functional issue |
| wk-skill scaffolds into wrong location | Task 5 updates wk-skill to prompt for group |
| AGENTS.md/README.md links 404 | Task 6 + Task 7 Step 4 verification |
