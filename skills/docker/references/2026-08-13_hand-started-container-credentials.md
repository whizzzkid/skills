---
class: principle
---

**Rule** — Before debugging private-registry auth failures in a hand-started container,
grep the project's setup/provisioning script for how it exports registry credentials
and replicate the exact env var name and value format — package managers use tool-specific
credential env var naming, not a generic API key var.

**Why** — A generic `<REGISTRY>_API_KEY` is almost never what the package manager reads;
each tool has its own naming convention. The project's own setup script is the
authoritative source for the correct format.

**Where** — `SKILL.md` → Hand-Started Containers: Replicate Setup-Script Credentials.
