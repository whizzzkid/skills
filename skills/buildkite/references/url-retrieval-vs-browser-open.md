---
class: principle
---

**Rule** — To retrieve a build URL, read `.web_url` from `--json` output; never run the `-w` / `--web` flag for that. Reserve `-w` for when the user explicitly asks to open the build in a browser.

**Why** — `-w` is a launch action, not a data-retrieval flag: it opens the default browser immediately, producing an unexpected tab. Conflating "get the URL" with "open in browser" surprises the user.

**Where** — Any CLI with an action flag that doubles as a side-effecting launcher. Distinguish data-retrieval flags from launch flags before invoking.
