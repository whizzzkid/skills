---
class: principle
---

# A stop before the gather still owes the user a stop report

- **Rule** — Any `start` stop ahead of Stage 2 (dirty tree, malformed `date:`, failed nested close or push, runtime
  absent) ends the response with the exact cause (each dirty path), the options (commit / stash / discard, or the
  fix), and `Connector gaps: unchecked — gather never ran`. Offer a push notification when a notify tool is available.
- **Why** — The connector report's "no gaps → omit the block" reads as "all connectors fine" when the gather never
  ran; a single terse stop line left the user unaware the run had halted and unsure what was and was not checked.
- **Where** — `SKILL.md` Core hard rules → publish-first → "Stop before gather" sub-bullet;
  `missed-end-rollover.md` failure line.
