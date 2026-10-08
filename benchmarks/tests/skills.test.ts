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

describe('pr_review_verdict', () => {
  it('passes when review opens with verdict', () => {
    const r = check('pr_review_verdict', 'LGTM — clean implementation with good test coverage.');
    assert.equal(r.pass, true);
  });

  it('fails when review opens with praise', () => {
    const r = check('pr_review_verdict', 'Great work on this PR! The implementation looks solid.');
    assert.equal(r.pass, false);
  });

  it('passes with neutral opening', () => {
    const r = check('pr_review_verdict', 'This PR adds retry logic to the HTTP client.');
    assert.equal(r.pass, true);
  });
});

describe('pr_review_severity', () => {
  it('passes when comments have severity prefix', () => {
    const r = check('pr_review_severity', 'concern: Race condition on line 42\nsuggestion: Extract to a helper\nquestion: Why not use the existing retry lib?');
    assert.equal(r.pass, true);
  });

  it('fails when comments lack severity prefix', () => {
    const r = check('pr_review_severity', '- Race condition on line 42\n- Should extract to a helper\n- Why not use the existing retry lib?');
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

describe('pr_resolve_no_pleasantries', () => {
  it('passes with direct reply', () => {
    const r = check('pr_resolve_no_pleasantries', 'Fixed by adding a nil check on line 42.');
    assert.equal(r.pass, true);
  });

  it('fails when reply starts with pleasantry', () => {
    const r = check('pr_resolve_no_pleasantries', 'Good catch! Fixed by adding a nil check on line 42.');
    assert.equal(r.pass, false);
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

describe('workflow_phases', () => {
  it('passes with correct phase order', () => {
    const r = check('workflow_phases', '1. Plan the change\n2. Implement the feature\n3. Test coverage\n4. Open PR for review');
    assert.equal(r.pass, true);
  });

  it('fails with wrong order', () => {
    const r = check('workflow_phases', '1. Review the code\n2. Implement the feature\n3. Plan the next steps');
    assert.equal(r.pass, false);
  });
});

describe('workflow_version_pins', () => {
  it('passes with exact pins', () => {
    const r = check('workflow_version_pins', '```yaml\nnode: "20.11.0"\n```');
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
});

describe('plan_numbered_steps', () => {
  it('passes with numbered steps and markers', () => {
    const r = check('plan_numbered_steps', '1. Read codebase [AGENT-READY]\n2. Implement feature [AGENT-GUIDED]\n3. Review with human [HUMAN-IN-LOOP]');
    assert.equal(r.pass, true);
  });

  it('fails without markers', () => {
    const r = check('plan_numbered_steps', '1. Read codebase\n2. Implement feature\n3. Review with human');
    assert.equal(r.pass, false);
  });

  it('fails with fewer than 2 steps', () => {
    const r = check('plan_numbered_steps', '1. Do the thing [AGENT-READY]');
    assert.equal(r.pass, false);
  });
});

// ── Code Quality Family ──────────────────────────────────────────────────

describe('adversarial_severity', () => {
  it('passes with severity in findings', () => {
    const r = check('adversarial_severity', 'Finding: SQL injection risk\nSeverity: blocker\nThe query concatenates user input.');
    assert.equal(r.pass, true);
  });

  it('fails without severity', () => {
    const r = check('adversarial_severity', 'Finding: SQL injection risk\nThe query concatenates user input.');
    assert.equal(r.pass, false);
  });
});

describe('testing_happy_sad', () => {
  it('passes with both paths', () => {
    const r = check('testing_happy_sad', 'Test the happy path: valid input returns success.\nTest the sad path: invalid input should throw an error.');
    assert.equal(r.pass, true);
  });

  it('fails with only happy path', () => {
    const r = check('testing_happy_sad', 'Test the happy path: valid input returns the expected result.');
    assert.equal(r.pass, false);
  });
});

describe('design_review_ranked', () => {
  it('passes with severity', () => {
    const r = check('design_review_ranked', 'Finding: Missing loading state\nSeverity: high\nThe button has no disabled state during submission.');
    assert.equal(r.pass, true);
  });

  it('fails without severity', () => {
    const r = check('design_review_ranked', 'Finding: Missing loading state\nThe button has no disabled state during submission.');
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
  it('passes with bk CLI', () => {
    const r = check('buildkite_bk_cli', 'Check Buildkite status: `bk build list --pipeline my-app`');
    assert.equal(r.pass, true);
  });

  it('fails with gh CLI for Buildkite', () => {
    const r = check('buildkite_bk_cli', 'Check Buildkite CI: `gh run list`');
    assert.equal(r.pass, false);
  });
});

describe('datadog_pup_cli', () => {
  it('passes with pup CLI', () => {
    const r = check('datadog_pup_cli', 'Create a Datadog dashboard: `pup dash create --title "API Latency"`');
    assert.equal(r.pass, true);
  });

  it('fails with raw curl', () => {
    const r = check('datadog_pup_cli', 'Create a Datadog dashboard:\n```\ncurl -X POST https://api.datadoghq.com/api/v1/dashboard\n```');
    assert.equal(r.pass, false);
  });
});

// ── Communication Family ─────────────────────────────────────────────────

describe('slack_mrkdwn', () => {
  it('passes with mrkdwn bold', () => {
    const r = check('slack_mrkdwn', 'Post this Slack message: *PR Ready for Review*');
    assert.equal(r.pass, true);
  });

  it('fails with Markdown bold', () => {
    const r = check('slack_mrkdwn', 'Post this Slack message: **PR Ready for Review**');
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

describe('markdown_wrap', () => {
  it('passes with short lines', () => {
    const r = check('markdown_wrap', 'This is a short line of prose.\nAnother short line.');
    assert.equal(r.pass, true);
  });

  it('fails with very long line', () => {
    const longLine = 'This is a very long line of prose that goes well beyond the 120 column limit and should be flagged by the grader because it violates the markdown wrapping convention established in the skill.';
    const r = check('markdown_wrap', longLine);
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
  it('passes when routing to learnings/', () => {
    const r = check('learn_routing', 'Saved learning to learnings/skills/pr-review/2026-10-08_finding.learned.md');
    assert.equal(r.pass, true);
  });

  it('fails when routing to memory/', () => {
    const r = check('learn_routing', 'Saved learning to .claude/memory/pr-review-learning.md');
    assert.equal(r.pass, false);
  });
});

describe('retro_structured', () => {
  it('passes with structured sections', () => {
    const r = check('retro_structured', '## Retrospective\n\n### What went well\nSmooth PR process.\n\n### What didn\'t\nCI flaked.\n\n### Action items\nAdd retry.');
    assert.equal(r.pass, true);
  });

  it('fails without structure', () => {
    const r = check('retro_structured', '## Retrospective\n\nThe session was productive. We shipped the feature on time.');
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
