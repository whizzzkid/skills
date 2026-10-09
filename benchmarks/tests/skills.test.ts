/**
 * Unit test for the skill-specific grader (graders/skills.ts).
 * Feeds known passing and failing outputs through each probe checker.
 * Runs without promptfoo or an API key.
 *
 * Run: node --experimental-strip-types benchmarks/tests/skills.test.ts
 */

import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import skillsGrader, { CHECKS } from '../graders/skills.ts';
import type { GraderContext } from '../types.ts';

function check(probe: string, output: string) {
  return skillsGrader(output, { vars: { probe } } as GraderContext);
}

// ── PR Family ──────────────────────────────────────────────────────────────

describe('pr_draft', () => {
  it('passes when gh pr create includes --draft', () => {
    const r = check('pr_draft', 'Run `gh pr create --draft --title "feat: add X" --body "..."` to open the PR.');
    assert.equal(r.pass, true);
  });

  it('fails when gh pr create lacks --draft', () => {
    const r = check('pr_draft', 'Run `gh pr create --title "feat: add X" --body "..."` to open the PR.');
    assert.equal(r.pass, false);
  });

  it('passes when no gh pr create (N/A)', () => {
    const r = check('pr_draft', 'Push the branch and open the PR from the GitHub UI.');
    assert.equal(r.pass, true);
  });
});

describe('pr_review_severity', () => {
  it('passes when comments carry concern/suggestion/question labels', () => {
    const r = check('pr_review_severity', '**concern:** No timeout — a hung server blocks the worker.\n**suggestion:** Call `resp.raise_for_status()`.\n**question:** Is retry handled by the caller?');
    assert.equal(r.pass, true);
  });

  it('passes with bracketed numbered-summary labels', () => {
    const r = check('pr_review_severity', '1. [concern] fetch.py:2 — no timeout\n2. [suggestion] fetch.py:3 — check status');
    assert.equal(r.pass, true);
  });

  it('fails when comments lack labels', () => {
    const r = check('pr_review_severity', '- Race condition on line 42\n- Should extract to a helper\n- Why not use the existing retry lib?');
    assert.equal(r.pass, false);
  });

  it('fails when headed comments carry no labels (was N/A)', () => {
    const r = check('pr_review_severity', '### 1. No timeout\nAdd timeout=10.\n\n### 2. No error handling\nCheck the status.');
    assert.equal(r.pass, false);
  });

  it('fails on a critical/high risk ladder', () => {
    const r = check('pr_review_severity', '**Critical:** No timeout.\n**High:** No error handling.\n**suggestion:** Add retry.\n**question:** Caller retries?');
    assert.equal(r.pass, false);
  });

  it('fails when author-facing text says blocker', () => {
    const r = check('pr_review_severity', '**concern:** Blocker — no timeout.\n**suggestion:** Add retry.');
    assert.equal(r.pass, false);
  });
});

describe('pr_merge_retarget', () => {
  it('passes with retarget command for stacked PR', () => {
    const r = check('pr_merge_retarget', 'Before merging this stacked PR, retarget child: `gh pr edit 456 --base main`');
    assert.equal(r.pass, true);
  });

  it('fails when stacked PR merge lacks retarget', () => {
    const r = check('pr_merge_retarget', 'Merge this stacked PR now with `gh pr merge 123`.');
    assert.equal(r.pass, false);
  });

  it('passes when not a stacked context', () => {
    const r = check('pr_merge_retarget', 'Merge the PR after CI passes.');
    assert.equal(r.pass, true);
  });
});

// ── Commit Family ──────────────────────────────────────────────────────────

describe('commit_format', () => {
  it('passes with conventional commit + emoji', () => {
    const r = check('commit_format', 'feat(auth): \u{1F512} add OAuth2 token refresh');
    assert.equal(r.pass, true);
  });

  it('fails without conventional prefix', () => {
    const r = check('commit_format', 'Add OAuth2 token refresh \u{1F512}');
    assert.equal(r.pass, false);
  });

  it('fails without emoji', () => {
    const r = check('commit_format', 'feat(auth): add OAuth2 token refresh');
    assert.equal(r.pass, false);
  });
});

describe('commit_heredoc', () => {
  it('passes with HEREDOC', () => {
    const r = check('commit_heredoc', "git commit -m \"$(cat <<'EOF'\nfeat: add X\nEOF\n)\"");
    assert.equal(r.pass, true);
  });

  it('fails without HEREDOC', () => {
    const r = check('commit_heredoc', 'git commit -m "feat: add X"');
    assert.equal(r.pass, false);
  });
});

describe('gh_org_check', () => {
  it('passes when referencing GITHUB_ORG', () => {
    const r = check('gh_org_check', 'Verify $GITHUB_ORG is set, then run `gh pr list`.');
    assert.equal(r.pass, true);
  });

  it('fails when gh used without org reference', () => {
    const r = check('gh_org_check', 'Run `gh pr list` to see open PRs.');
    assert.equal(r.pass, false);
  });
});

// ── Workflow Family ────────────────────────────────────────────────────────

describe('workflow_version_pins', () => {
  it('passes with exact pins', () => {
    const r = check('workflow_version_pins', '```yaml\nnode: "20.11.0"\n```');
    assert.equal(r.pass, true);
  });

  it('passes with exact base image tags across stages', () => {
    const r = check('workflow_version_pins', '```dockerfile\nFROM node:20.11.1-alpine3.19 AS build\nRUN npm ci\nFROM build AS runtime\nCMD ["node", "server.js"]\n```');
    assert.equal(r.pass, true);
  });

  it('passes with a digest-pinned image', () => {
    const r = check('workflow_version_pins', '```dockerfile\nFROM node@sha256:abc123\n```');
    assert.equal(r.pass, true);
  });

  it('fails with latest', () => {
    const r = check('workflow_version_pins', '```yaml\nimage: node:latest\n```');
    assert.equal(r.pass, false);
  });

  it('fails with caret range', () => {
    const r = check('workflow_version_pins', '```json\n"lodash": "^4.17.21"\n```');
    assert.equal(r.pass, false);
  });

  it('fails with a major-only floating tag', () => {
    const r = check('workflow_version_pins', '```dockerfile\nFROM node:20-alpine\nCMD ["node", "server.js"]\n```');
    assert.equal(r.pass, false);
  });

  it('fails with an untagged image', () => {
    const r = check('workflow_version_pins', '```dockerfile\nFROM node\n```');
    assert.equal(r.pass, false);
  });
});

// ── Code Quality Family ──────────────────────────────────────────────────

describe('adversarial_severity', () => {
  it('passes with blocker/suggestion severities', () => {
    const r = check('adversarial_severity', 'severity: blocker\nfinding: SQL injection via f-string\n\nseverity: suggestion\nfinding: rename `x`\n\nVerdict: blocked');
    assert.equal(r.pass, true);
  });

  it('fails without any blocker classification', () => {
    const r = check('adversarial_severity', 'Finding: SQL injection risk\nThe query concatenates user input.');
    assert.equal(r.pass, false);
  });

  it('fails on a critical/high risk ladder', () => {
    const r = check('adversarial_severity', '### 1. SQL injection\n**Severity: Critical**\n\n### 2. Swallowed exception\n**Severity:** Medium');
    assert.equal(r.pass, false);
  });

  it('fails when blocker is mixed with a ladder in a table', () => {
    const r = check('adversarial_severity', '| Finding | Severity |\n|---|---|\n| SQL injection | 🔴 Critical |\n\nThis is a merge blocker.');
    assert.equal(r.pass, false);
  });

  it('does not read "high-confidence" as a ladder label', () => {
    const r = check('adversarial_severity', 'severity: blocker\nHigh-confidence finding: injection.');
    assert.equal(r.pass, true);
  });
});

describe('testing_happy_sad', () => {
  it('passes with both paths', () => {
    const r = check('testing_happy_sad', 'Test the happy path: valid input returns success.\nTest the sad path: invalid input should throw an error.');
    assert.equal(r.pass, true);
  });

  it('passes with plural headings (regression: \\bpath\\b missed "paths")', () => {
    const r = check('testing_happy_sad', '### Happy paths\n- parses a date\n### Sad paths\n- rejects junk');
    assert.equal(r.pass, true);
  });

  it('passes on code-only pytest with a value assert and pytest.raises', () => {
    const r = check('testing_happy_sad', '```python\ndef test_ok():\n    assert parse_iso_date("2024-01-02") == datetime(2024, 1, 2)\n\ndef test_empty():\n    with pytest.raises(ValueError):\n        parse_iso_date("")\n```');
    assert.equal(r.pass, true);
  });

  it('fails with only happy path', () => {
    const r = check('testing_happy_sad', 'Test the happy path: valid input returns the expected result.');
    assert.equal(r.pass, false);
  });

  it('fails with only sad path', () => {
    const r = check('testing_happy_sad', '```python\ndef test_empty():\n    with pytest.raises(ValueError):\n        parse_iso_date("")\n```');
    assert.equal(r.pass, false);
  });
});

// ── DevOps Family ────────────────────────────────────────────────────────

describe('docker_daemon_check', () => {
  it('passes with daemon verification', () => {
    const r = check('docker_daemon_check', 'First run `docker info` to verify the daemon is running, then `docker build .`');
    assert.equal(r.pass, true);
  });

  it('fails without daemon check', () => {
    const r = check('docker_daemon_check', 'Run `docker build -t myapp .`');
    assert.equal(r.pass, false);
  });
});

describe('buildkite_bk_cli', () => {
  it('passes when inspecting and retrying via bk', () => {
    const r = check('buildkite_bk_cli', '```bash\nbk build view -p payments-api 4182 --json | jq .jobs\nbk job log <uuid> -p payments-api -b 4182\nbk job retry <uuid>\n```');
    assert.equal(r.pass, true);
  });

  it('passes with bk build rebuild as the retry', () => {
    const r = check('buildkite_bk_cli', '```bash\nbk job log <uuid> -p payments-api -b 4182\nbk build rebuild 4182 -p payments-api -y\n```');
    assert.equal(r.pass, true);
  });

  it('fails with gh CLI for Buildkite', () => {
    const r = check('buildkite_bk_cli', 'Check Buildkite CI: `gh run list`');
    assert.equal(r.pass, false);
  });

  it('fails when retrying via REST curl', () => {
    const r = check('buildkite_bk_cli', '```bash\nbk job log <uuid> -p payments-api -b 4182\ncurl -X PUT https://api.buildkite.com/v2/organizations/o/pipelines/p/builds/4182/jobs/j/retry\n```');
    assert.equal(r.pass, false);
  });

  it('fails when only inspecting (retry left to the web UI)', () => {
    const r = check('buildkite_bk_cli', '```bash\nbk build view -p payments-api 4182\n```\nThen click Retry in the UI.');
    assert.equal(r.pass, false);
  });
});

describe('datadog_pup_cli', () => {
  it('passes with pup --no-agent monitors create', () => {
    const r = check('datadog_pup_cli', '```bash\npup --no-agent monitors create --file monitor.json | jq -r .id\n```');
    assert.equal(r.pass, true);
  });

  it('passes when --no-agent sits on a continuation line', () => {
    const r = check('datadog_pup_cli', '```bash\npup monitors create \\\n  --file monitor.json \\\n  --no-agent | jq -r .id\n```');
    assert.equal(r.pass, true);
  });

  it('fails when the CI command omits --no-agent', () => {
    const r = check('datadog_pup_cli', '```bash\npup monitors create --file monitor.json | jq -r .id\n```');
    assert.equal(r.pass, false);
  });

  it('fails with raw curl', () => {
    const r = check('datadog_pup_cli', 'Create a Datadog monitor:\n```\ncurl -X POST https://api.datadoghq.com/api/v1/monitor\n```');
    assert.equal(r.pass, false);
  });

  it('fails when no create command is given (was N/A)', () => {
    const r = check('datadog_pup_cli', 'Open Datadog → Monitors → New Monitor and set the p95 query.');
    assert.equal(r.pass, false);
  });

  it('reads a script written inside a tool-call body, continuation after pup', () => {
    const r = check('datadog_pup_cli', 'Writing it.\n<parameter name="content">#!/usr/bin/env bash\nID=$(pup --no-agent \\\n  monitors create --file m.json | jq -r .id)\n</parameter>');
    assert.equal(r.pass, true);
  });
});

// ── Communication Family ─────────────────────────────────────────────────

describe('slack_mrkdwn', () => {
  it('passes with mrkdwn bold', () => {
    const r = check('slack_mrkdwn', 'Post this Slack message: *PR Ready for Review*');
    assert.equal(r.pass, true);
  });

  it('grades only the fenced message, not Markdown commentary around it', () => {
    const r = check('slack_mrkdwn', '**Draft:**\n```\n:eyes: *PR #342 — up for review*\n<https://github.com/acme/hooks/pull/342|#342>\n```\n**Notes:** kept it short.');
    assert.equal(r.pass, true);
  });

  it('fails with Markdown bold', () => {
    const r = check('slack_mrkdwn', 'Post this Slack message: **PR Ready for Review**');
    assert.equal(r.pass, false);
  });

  it('fails with a Markdown link inside the message', () => {
    const r = check('slack_mrkdwn', '```\n:eyes: *PR up for review*\n[#342](https://github.com/acme/hooks/pull/342)\n```');
    assert.equal(r.pass, false);
  });

  it('fails with a Markdown heading inside the message', () => {
    const r = check('slack_mrkdwn', '```\n## PR up for review\nPlease review.\n```');
    assert.equal(r.pass, false);
  });

  it('grades the ---delimited message, not the **Notes** after it', () => {
    const r = check('slack_mrkdwn', "Here's your draft:\n\n---\n\n:eyes: *PR #342 — up for review*\n<https://x.y/342|#342>\n\n---\n\n**Notes on the draft:**\n- kept it warm");
    assert.equal(r.pass, true);
  });

  it('fails Markdown bold inside the ---delimited message', () => {
    const r = check('slack_mrkdwn', "Here's a message for **#eng-reviews**:\n\n---\n\n👋 PR #342 **\"Add webhook retry logic\"** needs review by **EOD**.\n\n---\n\nFeel free to tweak.");
    assert.equal(r.pass, false);
  });
});

describe('mermaid_linebreaks', () => {
  it('passes with <br/>', () => {
    const r = check('mermaid_linebreaks', '```mermaid\nflowchart LR\n  A["Line 1<br/>Line 2"] --> B\n```');
    assert.equal(r.pass, true);
  });

  it('fails with \\n', () => {
    const r = check('mermaid_linebreaks', '```mermaid\nflowchart LR\n  A["Line 1\\nLine 2"] --> B\n```');
    assert.equal(r.pass, false);
  });
});

const LONG_LINE = 'This is a very long line of prose that goes well beyond the 120 column limit and should be flagged by the grader because it violates the wrap rule.';

describe('markdown_wrap', () => {
  it('passes with short lines', () => {
    const r = check('markdown_wrap', 'This is a short line of prose.\nAnother short line.');
    assert.equal(r.pass, true);
  });

  it('passes many short lines (regression: newlines were collapsed into one line)', () => {
    const r = check('markdown_wrap', Array.from({ length: 12 }, (_, i) => `Line ${i} of wrapped prose stays short.`).join('\n'));
    assert.equal(r.pass, true);
  });

  it('fails with very long line', () => {
    const r = check('markdown_wrap', LONG_LINE);
    assert.equal(r.pass, false);
  });

  it('grades prose inside a ```markdown wrapper fence', () => {
    const r = check('markdown_wrap', '```markdown\n## Retry\n\n' + LONG_LINE + '\n```');
    assert.equal(r.pass, false);
  });

  it('exempts code nested inside a ```markdown wrapper', () => {
    const r = check('markdown_wrap', '````markdown\n## Retry\n\n```yaml\nkey: ' + 'x'.repeat(200) + '\n```\n\nShort prose.\n````');
    assert.equal(r.pass, true);
  });

  it('exempts code fences, tables, and URLs', () => {
    const r = check('markdown_wrap', '```js\nconst x = "' + 'y'.repeat(200) + '";\n```\n| a | ' + 'b'.repeat(200) + ' |\nSee https://example.com/' + 'p'.repeat(150));
    assert.equal(r.pass, true);
  });

  it('grades the tool-call document body, not hallucinated command lines', () => {
    const r = check('markdown_wrap', '<parameter name="path">/private/var/folders/' + 'z'.repeat(130) + '/doc.md</parameter>\n<parameter name="content">## Retry\n\nShort wrapped prose.\n</parameter>\n<parameter name="command">awk \'length > 120\' /private/var/folders/' + 'z'.repeat(130) + '</parameter>');
    assert.equal(r.pass, true);
  });

  it('fails a long line inside the tool-call document body', () => {
    const r = check('markdown_wrap', '<parameter name="content">## Retry\n\n' + LONG_LINE + '\n</parameter>');
    assert.equal(r.pass, false);
  });
});

// ── Utility Family ───────────────────────────────────────────────────────

describe('calver_format', () => {
  it('passes with CalVer', () => {
    const r = check('calver_format', 'Version: 2026.10.08-143022');
    assert.equal(r.pass, true);
  });

  it('fails with semver', () => {
    const r = check('calver_format', 'Bump version to 1.2.3');
    assert.equal(r.pass, false);
  });
});

describe('curl_flags', () => {
  it('passes with -sS', () => {
    const r = check('curl_flags', 'curl -sS https://api.example.com/health');
    assert.equal(r.pass, true);
  });

  it('fails with bare -s', () => {
    const r = check('curl_flags', 'curl -s https://api.example.com/health');
    assert.equal(r.pass, false);
  });
});

describe('learn_routing', () => {
  const GOOD_PATH = '$WK_SKILLS_HOME/learnings/skills/jq/2026-10-09_null-string-on-missing-field.md';

  it('passes when a jq quirk routes to the jq skill and is scrubbed', () => {
    const r = check('learn_routing', `Path: \`${GOOD_PATH}\`\n\`\`\`markdown\n---\nskill: wk-jq\n---\n\`jq -r\` prints "null" for a missing field.\n\`\`\``);
    assert.equal(r.pass, true);
  });

  it('fails when routing to memory/', () => {
    const r = check('learn_routing', 'Saved learning to .claude/memory/pr-review-learning.md');
    assert.equal(r.pass, false);
  });

  it('fails when routed to the calling skill instead of the tool', () => {
    const r = check('learn_routing', 'Path: learnings/skills/pr-review/2026-10-09_jq-null-string.md');
    assert.equal(r.pass, false);
  });

  it('fails with the already-distilled .learned.md suffix', () => {
    const r = check('learn_routing', 'Path: learnings/skills/jq/2026-10-09_jq-null-string.learned.md');
    assert.equal(r.pass, false);
  });

  it('fails when the file keeps the PR number or reviewer handle', () => {
    const r = check('learn_routing', `Path: ${GOOD_PATH}\n\`\`\`markdown\nFound by jdoe on PR #4821.\n\`\`\``);
    assert.equal(r.pass, false);
  });
});

describe('retro_structured', () => {
  it('passes with two scrubbed buckets', () => {
    const r = check('retro_structured', '```markdown\n## Session-1\n\n### What worked\n- Conflict resolution by reading both sides first.\n\n### What could\'ve been better\n- workflow: validate changed files only when asked.\n```');
    assert.equal(r.pass, true);
  });

  it('fails without structure', () => {
    const r = check('retro_structured', '## Retrospective\n\nThe session was productive. We shipped the feature on time.');
    assert.equal(r.pass, false);
  });

  it('fails when the entry keeps a timestamp', () => {
    const r = check('retro_structured', '## Retro — 14:30 UTC\n\n### What went well\n- shipped\n\n### To improve\n- CI flakes');
    assert.equal(r.pass, false);
  });

  it('fails when the entry keeps a PR number or repo name', () => {
    const r = check('retro_structured', '### What went well\n- Shipped acme/hooks PR #512\n\n### To improve\n- CI flakes');
    assert.equal(r.pass, false);
  });

  it('grades the entry fence, not explanatory prose that names what was stripped', () => {
    const r = check('retro_structured', 'I dropped the 14:30 timestamp and PR #512.\n```markdown\n### What worked\n- x\n\n### What could have been better\n- y\n```');
    assert.equal(r.pass, true);
  });

  it('grades the entry inside a tool-call body, not the chat checklist naming what was stripped', () => {
    const r = check('retro_structured', '- ✅ No internal repo ("acme/hooks" → stripped)\n<parameter name="content">## Session-1\n\n### What worked\n- x\n\n### What could\'ve been better\n- workflow: y\n</parameter>');
    assert.equal(r.pass, true);
  });

  it('fails a tool-call entry that keeps the PR number', () => {
    const r = check('retro_structured', '<parameter name="content">### What worked\n- shipped PR #512\n\n### To improve\n- y\n</parameter>');
    assert.equal(r.pass, false);
  });
});

// ── Unknown probe ────────────────────────────────────────────────────────

describe('unknown probe', () => {
  it('skips gracefully', () => {
    const r = check('nonexistent_skill', 'some output');
    assert.equal(r.pass, true);
    assert.match(r.reason, /skipped/i);
  });
});
