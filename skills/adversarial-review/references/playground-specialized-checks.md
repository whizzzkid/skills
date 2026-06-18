# Playground — specialized & doc-diff checks

Conditional Step 5 checks. Apply the matching block when the diff shape calls for
it; the core playground rules stay in `SKILL.md` Step 5.

## Runtime matrix

Run every interpreter the diff exercises, not whatever is first on `PATH`; flag any missing runtime for CI rather than silently skipping.

| Diff includes | Run under |
|---|---|
| `*.sh`, `*.bash`, `Brewfile`, shebanged shell | macOS bash 3.2 and modern bash; flag bash 4+ idioms. |
| `*.py` | each Python version in `requires-python` or CI. |
| `*.js`, `*.ts`, `package.json` engines change | each Node version in `engines.node`, `.nvmrc`, or CI. |
| `*.rb`, `Gemfile.lock` | each Ruby version in `.ruby-version` or CI. |
| `Dockerfile`, GH Actions matrix | each `runs-on` / base image listed. |

## Specialized checks (apply when the diff shape matches)

- **Producer→consumer layout:** populate staging dir with real producer layout; run consumer end-to-end. Verify path/key match, recursion depth, fixture placement, cleanup-after-consume ordering.
- **Cluster promotion/dedup:** test guard checks the chosen representative, not just the iteration anchor; iterate in reverse and non-sequential order.
- **Interface contract change:** run old shapes through new code and new shapes through old consumers.
- **Allowlist/privilege add:** compare new entry against existing siblings, not an empty list; note when strictly less privileged than a present entry.
- **Cross-step file persistence:** before flagging that a file written in one CI step won't reach a later step, grep the pipeline templates for `artifact_upload`/`artifact_download` (or `artifacts: upload`/`download`) matching that path. Confirmed upload+download resolves the concern → do not surface it. Script-level I/O crossing step boundaries always has a pipeline artifact contract; read the orchestration layer, not just the source.

## Documentation / prose / compression diffs — read-based analysis

When every changed file is docs, prompt/rule text, or non-executable fixture data, skip scratch scripts; substitute a read-based adversarial pass under `.review-playground/`:

- Cover ambiguity, contradictions, missing cases, edge-case prompts.
- Cross-check every numeric count in tables/enumerated claims against the actual items.
- **Compression/debloat diffs:** verify rule survival by *substance*, not by counting `HARD RULE` (or similar) labels — labels are trimmed first even when the rule they tagged is preserved, so label-count deltas are noise in either direction. Enumerate each gate the commit claims to preserve and content-grep it against the new file. With `grep -E`, write alternation as `a|b`; `\|` matches a literal pipe and silently returns zero (a false "missing gate").
- **Relocations:** flag org-specific tooling names, command aliases, internal script names, tracker IDs, short-link prefixes, or source-only paths absent from the destination repo; fix back-references to un-imported files.
- Flag committed absolute/home/worktree paths, local-only branches, or personal artifacts stated as permanent facts.
- Doc names a live code file as authoritative → read that file, verify stated constraints against the current branch.
