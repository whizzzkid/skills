---
class: principle
---

# User focus steers depth, never scope or the review body

**Rule**

- Trailing free text after mode / `approve` / PR = `user_focus`; positional parsing keeps an `approve` word inside the
  focus from flipping the flag.
- Focus items join `review_focus` as `source: user`, rank ahead of author asks, and get at least one targeted
  adversarial run in every mode, including `light`.
- Extra care, not exclusive scope: the full diff is still reviewed.
- Report focus outcomes in the terminal only; the review body never quotes or answers the user's private steering.

**Why**

- A reviewer often knows where risk hides; without a channel for it, the agent spreads depth evenly.
- Treating focus as scope would silently drop findings elsewhere; echoing it on GitHub would leak the user's private
  intent into an author-facing artifact.

**Where** — `SKILL.md` → Focus Argument; Phase 1 announce line; Phase 4 `review_focus` answer bullet; Phase 5 body
exceptions.
