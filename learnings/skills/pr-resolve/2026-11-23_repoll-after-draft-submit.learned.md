---
skill: wk-pr-resolve
date: 2026-11-23
type: correction
severity: medium
verified-against-source: n/a
---

A bot thread whose reply waited in the user's pending review was left unreacted and unresolved after the user submitted it.

**What happened:** The agent deferred the reaction and resolution until the user submitted the draft that held the reply. On the next status check it reported the thread as open work for the user and never checked whether the draft had since been submitted.

**Root cause:** The deferred actions were not re-checked against the live reply state at the next turn.

**Suggested fix:** On every status report, re-query each deferred thread's reply `state`. Once it reads SUBMITTED, add the reaction and resolve the thread in the same turn, without waiting to be asked.
