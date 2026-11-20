---
skill: wk-find-cli
date: 2026-11-20
type: correction
severity: low
verified-against-source: n/a
---

To verify a claim about a vendored gem asset, the agent ran `find /` and hit a 60s timeout.

**What happened:** The agent needed the JS bundle a Rails gem ships. It searched from the filesystem root, which broke
the PWD-scoped rule and stalled until the 60s timeout moved the command to the background.

**Root cause:** It did not resolve the gem's install path first. The tool manager's gem directory, or `bundle show
<gem>`, gives the location in one call.

**Suggested fix:** Add to wk-find-cli: to find a package or gem asset, resolve its install dir first
(`bundle show <gem>`, `gem contents <gem>`, `ls -d <tool-manager>/installs/ruby/*/lib/ruby/gems/*/gems/<gem>-*`),
then search only inside it. Never `find /`.
