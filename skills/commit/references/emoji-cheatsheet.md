# Commit Emoji Cheatsheet

Full reference for all supported commit emojis used by `wk-commit`.

## Primary action emojis

| Action | Emoji | Example |
|--------|-------|---------|
| `feat` | ✨ | `feat(auth): ✨ add OAuth2 login` |
| `fix` | 🐛 | `fix(parser): 🐛 handle empty input` |
| `refactor` | ♻️ | `refactor(api): ♻️ extract middleware` |
| `docs` | 📝 | `docs(readme): 📝 update install guide` |
| `test` | 🧪 | `test(auth): 🧪 add token expiry tests` |
| `chore` | 🔧 | `chore(config): 🔧 tune lefthook timeouts` |
| `chore` | 🗑️ | `chore: 🗑️ remove dead code` |
| `ci` | 👷 | `ci(deploy): 👷 add staging pipeline` |
| `revert` | ⏪ | `revert(api): ⏪ revert middleware extraction` |
| `perf` | ⚡ | `perf(query): ⚡ index hot lookup column` |
| `style` | 🎨 | `style(ui): 🎨 align card padding` |
| `build` | 🏗️ | `build(deps): 🏗️ lock new dep tree` |

## Classifier / modifier emojis

When an action emoji alone underspecifies the intent, append one or more
classifier emojis after it. Classifiers carry signal that future readers
(and `git log`-grep) can scan without parsing the message body.

| Emoji | Meaning | Example |
|-------|---------|---------|
| 🔧 | Tuning configs (in-tool knobs, thresholds) | `chore(ci): 🔧 raise {tool} timeout to 60s` |
| 📌 | Version pinned (was unpinned / floating) | `chore(deps): 📌 pin {dep} to {version}` |
| ⬆️ | Version bump (upgrade) | `chore(deps): ⬆️ bump rust 1.93 → 1.94` |
| ⬇️ | Version downgrade | `fix(ci): ⬇️ downgrade {dep} 0.24 → 0.23` |
| 🦾 | Agentic tool strengthening (skill / hook / agent capability) | `feat(skill): 🦾 add idempotency gate to wk-goodmorning` |
| 🛡️ | Adding guardrails (validation, gate, policy enforcement) | `feat(commit): 🛡️ enforce PR sync after push` |
| 🔒 | Security fix or hardening | `fix(auth): 🔒 reject unsigned tokens` |
| 🔥 | Removed code / files / features | `refactor: 🔥 drop deprecated v1 routes` |
| 🚨 | Fix lint / type / static-analysis warning | `fix(lint): 🚨 resolve clippy warnings` |
| 💚 | Fix failing CI | `fix(ci): 💚 install {tool} directly` |
| 🚧 | Work-in-progress (use sparingly; prefer drafts) | `feat(parser): 🚧 partial AST walker` |
| 🩹 | Small non-critical fix | `fix(ui): 🩹 trim trailing whitespace` |
| ♿ | Accessibility improvement | `feat(ui): ♿ add ARIA labels to nav` |
| 🌐 | Internationalization / localization | `feat(i18n): 🌐 add fr-CA translations` |
| 🚸 | UX improvement | `feat(ux): 🚸 friendlier error copy on form submit` |
| 🚀 | Deploy / release-related | `chore(release): 🚀 cut v2026.04.27` |
| ⏱️ | Performance — latency-specific | `perf(api): ⏱️ cache hot endpoint` |
| 🔐 | Touching secrets / keys / credentials | `chore(env): 🔐 rotate signing key` |
| 🛞 | Re-inventing the wheel — flag for review | `feat(util): 🛞 custom retry helper (lib X already does this)` |
| 🧪 | Test-only commit (paired with `test` action) | `test(auth): 🧪 cover token expiry` |
| 🎨 | Readability / code-as-art polish | `refactor(parser): 🎨 rename for clarity` |
| 🤖 | Fallback when no other emoji fits | `chore: 🤖 mixed cleanup across modules` |
