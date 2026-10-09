# Conditional authoring rules (Step 6)

Apply each rule when its trigger matches.

**HARD RULE — sub-command state must define a deterministic fallback.** Any sub-command (e.g., `/wk-foo:bar`) reading
session-scoped state (active mode, active config, current context) must state the behavior when that state is
absent: pick a default, document it in the body, and emit a one-line confirmation naming the resolved state
(`"compressing using mode: brief (default — no active mode)"`). Never refuse or silently guess.

**HARD RULE — supersede parity audit.** When the user frames the new skill as replacing/superseding/deprecating
existing skills ("replaces X", "instead of X", "deprecate X once this ships"), audit each named skill for feature
parity before declaring done:

- Read each superseded skill's `SKILL.md`, extract its stage/feature list.
- Confirm the new skill covers each feature, or record an explicit, intentional exclusion in the body.
- Keep the deprecated file when the new skill links to it as a spec source — deprecation marks it superseded;
  deletion orphans the reference.

**Removal / rename obligation.** This skill only *adds*. On removal or rename, the same commit MUST delete or update
its row in **both** indexes (and header counts) — `check-readme-index` flags an orphan row pointing at a deleted
directory. A material `group:` or `description:` change likewise updates both indexes.
