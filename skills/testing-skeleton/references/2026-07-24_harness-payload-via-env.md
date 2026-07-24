---
class: principle
---

**Rule** — Never interpolate the input under test into a shell command string in a fixture.
Export it and read it inside the child process instead.

**Why** — A single-quote-wrapped interpolation closes on the first quote character present in
the input, silently mangling the payload before the artifact sees it. Only the one case whose
input contains a quote fails, and it fails as a plausible assertion mismatch rather than an
error — so the failure reads as evidence about the code under test, not about the fixture.
The diagnostic signature is a newly added case going red while every pre-existing case passes.

**Where** — Stage 3, alongside the other shell-harness construction gotchas.

**Scope note** — Not duplicated into the shell workstyle skill: that skill governs shell
authoring generally, while this is a fixture-construction rule and belongs where an agent
writing a new test case will already be reading.
