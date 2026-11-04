---
class: principle
---

# HTML entities in span text render literally

- **Rule:** Never write HTML entities (`&lt;`, `&gt;`, `&amp;`) in span text inside a SilverBullet HTML block. Replace
  angle brackets with a plain separator glyph; assert rendered page text holds no literal entity.
- **Why:** A generated page wrote a meeting title's angle brackets as `&lt;&gt;` inside info spans; the render-verify
  screenshot showed the literal entity text. Verified in the browser: a plain separator fixed it, and a body-text check
  confirmed no literal `&lt;` remained. Sibling of the existing pre-escaped `&&`-in-onclick rule.
- **Where:** [`wk-silverbullet`](../README.md) → Common Mistakes. Consumer: [`wk-sitrep`](../../sitrep/README.md)
  rendering contract and Stage 5 render gate (Text clause).
