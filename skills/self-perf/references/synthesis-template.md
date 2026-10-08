# Synthesis Template

## Evidence-Integrity Checks

- Enumerate dated milestones before claiming an event was first, earliest, latest, or final.
- Distinguish similarly named execution units with stable identifiers before comparing their outcomes.
- Treat a non-significant result as insufficient evidence of an effect, never evidence that no effect exists.
- Preserve the measured effect, uncertainty, and significance threshold when translating statistics into prose.

## Revision Boundaries

- Record sections the user marks final, approved, or keep-as-is before each polish pass.
- Exclude protected sections from broad rewrites, condensation, tone changes, and formatting edits.
- Reopen protected content only when the user explicitly names that section for revision.

## Synthesis Structure

```markdown
# Self-Performance Review — {DISPLAY_PERIOD}
**Period:** {START_DATE_DISPLAY} – {END_DATE_DISPLAY}
**Role:** {ROLE} — confirm or update before submitting
**Compiled:** {TODAY}

## Executive Summary
{3-4 sentences: what you shipped, the impact, and one standout signal}

## Major Accomplishments

### 1. {Largest shipped feature/system}
**What:** {one-line description}
**Key milestones:** {bulleted timeline with specific evidence}
**Impact:** {outcomes, metrics, reach}
**Evidence:** {PR numbers, Jira keys, meeting dates}

### 2. {Next accomplishment}
...

## Team & People Impact
- Direct reports managed: {names, cadence}
- Interviews conducted: {count, levels, orgs, outcomes}
- Training facilitated: {sessions, hours, engineers reached}
- Peers unblocked: {notable examples}

## Technical Leadership
- Architecture decisions made: {ADRs authored, design docs, key choices}
- Security work: {hardening, threat models, reviews}
- Platform contributions: {cross-team tools, shared libraries}

## Cross-Team Impact
- Teams collaborated with: {list with nature of collaboration}
- Cross-team PRs: {repos contributed to outside your own}
- External visibility: {talks, events, blog posts}

## DX / Engineering Health
- PR velocity: {avg/period}
- Review quality: {notes}
- Documentation: {every feature shipped with docs?}
- Test coverage: {patterns}

## Quarter Narrative (Suggested Self-Review Language)
> {2-3 paragraph first-person narrative ready to paste into Lattice/QPR tool}
```

> ⚠️ **Role placeholder:** The synthesis template uses `{ROLE}`. Before writing
> the file, resolve the user's current role from Workday, Lattice, or their
> GitHub profile bio. If unresolvable, leave the placeholder and flag it.

## Impact Language Guide

When synthesizing, prefer strong over weak verbs:

| Weak | Strong |
|------|--------|
| "worked on" | "designed and shipped" |
| "helped with" | "led", "unblocked", "enabled" |
| "made changes to" | "hardened", "refactored", "extracted" |
| "participated in" | "co-facilitated", "presented at", "drove" |
| "was involved in" | "owned end-to-end", "drove to completion" |

## Calibrating to Level Expectations

Structure the narrative to demonstrate the user's level expectations.
For the user's current level at $EMPLOYER, surface these signals:

| L4 Signal | Evidence to surface |
|-----------|---------------------|
| Ships impactful projects end-to-end | Feature milestones with dates and metrics |
| Drives cross-team collaboration | Orgs collaborated with, PRs in other repos |
| Mentors and grows team members | 1:1s, hiring contributions, unblocking patterns |
| Writes and owns technical design | ADRs, design docs, architecture decisions |
| Improves team processes | Automation built, CI improvements, workflow changes |
| External visibility | Talks, blog posts, industry engagement |
