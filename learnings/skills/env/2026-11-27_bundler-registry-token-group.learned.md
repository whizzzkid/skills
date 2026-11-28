---
skill: wk-env
date: 2026-11-27
type: correction
severity: medium
verified-against-source: yes
---

A private gem registry's Bundler token is provisioned by its own setup-tool group, not the registry login group.

**What happened:** A host `bundle install` failed with "Bad username or password" from the private gem registry. The
agent retried with a personal registry API key exported as a Bundler env override; the user corrected that and ran the
registry *login* doctor group, which passed but left the user-level Bundler config untouched (old mtime), so install
still failed. Listing the doctor groups showed a separate `<registry>-bundler` group that writes the Bundler
entitlement token; running it plus the `bundle-install` group fixed the bundle.

**Root cause:** The setup tool splits registry auth into a CLI login group and per-package-manager token groups; only
the latter writes Bundler credentials.

**Suggested fix:** On a registry auth failure from Bundler, list the setup tool's doctor groups, run the
package-manager-specific token group and the install group; never substitute a personal API key. Check the Bundler
config file's mtime to confirm a fix actually rewrote it.
