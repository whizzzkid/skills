/**
 * Skill-specific grader: does each skill family produce its intended behaviors?
 *
 * One check per regex-graded probe (vars.probe), each targeting a concrete rule
 * from the skill's SKILL.md. Semantic probes (pr_review_verdict,
 * pr_resolve_no_pleasantries, workflow_phases, plan_numbered_steps,
 * design_review_ranked) are graded by `llm-rubric` in
 * promptfooconfig-skills.yaml instead. Heuristic graders proven by
 * tests/skills.test.ts (RED/GREEN, no API key needed).
 *
 * Metric: `skill_behavior` (1 = behavior present, 0 = absent).
 */

import type { GraderResult, GraderContext, ProbeChecker, ProbeCheckers } from '../types.ts';

const MAX_LINE_COLUMNS = 120;
const MIN_LABELED_COMMENTS = 2;

function codeOf(text: string): string {
  const blocks = [...text.matchAll(/```[a-zA-Z0-9_+-]*\r?\n([\s\S]*?)```/g)].map(m => m[1]);
  return blocks.length ? blocks.join('\n') : '';
}

function fencesOf(text: string): string[] {
  return [...text.matchAll(/```[a-zA-Z0-9_+-]*\r?\n([\s\S]*?)```/g)].map(m => m[1]);
}

/**
 * The artifact the reply delivers, apart from chat around it: the body of a
 * (hallucinated) Write tool call, else a fenced block, else the text between
 * `---` rules, else the whole reply. `prefer` picks among several candidates.
 */
function artifactOf(text: string, prefer: RegExp = /[\s\S]/): string {
  const toolBodies = [...text.matchAll(/<parameter name="content">(?<body>[\s\S]*?)<\/parameter>/g)].map(m => m.groups!.body);
  const ruled = text.split(/^\s*-{3,}\s*$/m).slice(1, -1);
  for (const candidates of [toolBodies, fencesOf(text), ruled]) {
    if (candidates.length) return candidates.find(c => prefer.test(c)) ?? candidates[0];
  }
  return text;
}

/** Shell line continuations joined, so a flag on the next line counts as the same command. */
function joinContinuations(text: string): string {
  return text.replace(/\\\r?\n\s*/g, ' ');
}

const DOC_FENCE_LANGS = new Set(['markdown', 'md', '']);

/**
 * Lines a reader sees as prose: everything outside code fences. A ```markdown
 * (or bare) fence wrapping the whole answer is the document itself, so its body
 * counts as prose; code fences nested inside it do not.
 */
function proseLinesOf(text: string): string[] {
  const prose: string[] = [];
  const stack: { marker: string; isDoc: boolean }[] = [];
  for (const line of text.split('\n')) {
    const fence = line.match(/^\s*(?<marker>`{3,}|~{3,})\s*(?<lang>[\w+-]*)\s*$/);
    if (fence?.groups) {
      const { marker, lang } = fence.groups;
      const top = stack[stack.length - 1];
      const closesTop = top && !lang && marker[0] === top.marker[0] && marker.length >= top.marker.length;
      if (closesTop) stack.pop();
      else stack.push({ marker, isDoc: !top && DOC_FENCE_LANGS.has(lang.toLowerCase()) });
      continue;
    }
    if (stack.every(f => f.isDoc)) prose.push(line);
  }
  return prose;
}

// Severity scales other than the skills' own (risk/priority ladders).
const FOREIGN_SEVERITY = [
  /(?:severity|risk|priority|impact)\s*(?:\*\*)?\s*[:=|]\s*(?:\*\*)?\s*\p{Extended_Pictographic}?\s*(?:critical|high|medium|low|major|minor)\b/iu,
  /[[(]\s*(?:critical|high|medium|low|major|minor)\s*[\])]/i,
  /^\s*(?:[-*]\s+|\d+[.)]\s+|#{1,6}\s+)?(?:\*\*)?\s*\p{Extended_Pictographic}?\s*(?:critical|high|medium|low|major|minor)\s*(?:\*\*)?\s*(?::|\s[—–-]\s)/imu,
  /\|\s*(?:\*\*)?\s*\p{Extended_Pictographic}?\s*(?:critical|high|medium|low|major|minor)\s*(?:\*\*)?\s*\|/iu,
];
const usesForeignSeverity = (text: string): boolean => FOREIGN_SEVERITY.some(re => re.test(text));

// ── PR Family ──────────────────────────────────────────────────────────────

// A review comment labeled `concern:` / `**suggestion:**` / `[question]` / `Praise:`.
const REVIEW_LABEL = /(?:^|[\s>|(—-])(?:\*\*|__|`|\[)\s*(?:concern|suggestion|question|praise)\s*(?:\*\*|__|`)?\s*[:\]]|^\s*(?:[-*]\s+|\d+[.)]\s+)?(?:concern|suggestion|question|praise)\s*:/gim;

const CHECKS: ProbeCheckers = {
  /** PR creation must use --draft flag. */
  pr_draft(output: string) {
    const hasGhPrCreate = /gh\s+pr\s+create/i.test(output);
    if (!hasGhPrCreate) return { pass: true, reason: 'No gh pr create command found (N/A).' };
    const hasDraft = /--draft/i.test(output);
    return hasDraft
      ? { pass: true, reason: 'gh pr create includes --draft flag.' }
      : { pass: false, reason: 'gh pr create missing --draft flag.' };
  },

  /** Review comments carry concern:/suggestion:/question:/praise: labels; never "blocker" or a risk ladder. */
  pr_review_severity(output: string) {
    const labeled = (output.match(REVIEW_LABEL) || []).length;
    if (/\bblocker\b/i.test(output)) return { pass: false, reason: 'Author-facing comments use "blocker".' };
    if (usesForeignSeverity(output)) return { pass: false, reason: 'Comments use a critical/high/medium/low ladder, not concern/suggestion/question.' };
    return labeled >= MIN_LABELED_COMMENTS
      ? { pass: true, reason: `${labeled} comments carry a concern/suggestion/question/praise label.` }
      : { pass: false, reason: `Only ${labeled} labeled comment(s); need ${MIN_LABELED_COMMENTS}+ with concern:/suggestion:/question:/praise:.` };
  },

  /** PR merge must retarget stacked children. */
  pr_merge_retarget(output: string) {
    const t = output.toLowerCase();
    const mentionsMerge = /\bmerge\b/.test(t);
    const mentionsStack = /\bstack(ed)?\b/.test(t);
    if (!mentionsMerge || !mentionsStack) return { pass: true, reason: 'Not a stacked-PR merge context (N/A).' };
    const hasRetarget = /gh\s+pr\s+edit.*--base/i.test(output) || /retarget/i.test(output);
    return hasRetarget
      ? { pass: true, reason: 'Retargets stacked children before merge.' }
      : { pass: false, reason: 'Stacked PR merge missing retarget step (gh pr edit --base).' };
  },

  // ── Commit Family ──────────────────────────────────────────────────────

  /** Commit message must follow conventional format with emoji. */
  commit_format(output: string) {
    const commitPattern = /\b(feat|fix|chore|refactor|docs|test|ci|perf|build|style|revert)\s*(\([^)]+\))?\s*:\s*\S/i;
    const hasConventional = commitPattern.test(output);
    const hasEmoji = /[\u{1F300}-\u{1FFFF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]/u.test(output);
    if (hasConventional && hasEmoji) return { pass: true, reason: 'Conventional commit with emoji.' };
    if (!hasConventional) return { pass: false, reason: 'Missing conventional commit prefix (feat/fix/chore/etc.).' };
    return { pass: false, reason: 'Missing emoji in commit message.' };
  },

  /** Commit must use HEREDOC for message. */
  commit_heredoc(output: string) {
    const hasGitCommit = /git\s+commit/i.test(output);
    if (!hasGitCommit) return { pass: true, reason: 'No git commit command found (N/A).' };
    const hasHeredoc = /<<\s*'?EOF'?/i.test(output);
    return hasHeredoc
      ? { pass: true, reason: 'Uses HEREDOC for commit message.' }
      : { pass: false, reason: 'git commit should use HEREDOC for message body.' };
  },

  /** GH commands must reference GITHUB_ORG. */
  gh_org_check(output: string) {
    const hasGhCommand = /\bgh\s+(pr|issue|repo|api)\b/i.test(output);
    if (!hasGhCommand) return { pass: true, reason: 'No gh command found (N/A).' };
    const hasOrgRef = /GITHUB_ORG|\$GITHUB_ORG|\bgithub.org\b/i.test(output);
    return hasOrgRef
      ? { pass: true, reason: 'References GITHUB_ORG.' }
      : { pass: false, reason: 'gh command without GITHUB_ORG reference.' };
  },

  // ── Workflow Family ──────────────────────────────────────────────────────

  /** Base images pinned to an exact version (x.y.z tag or digest); no floating tags or ranges. */
  workflow_version_pins(output: string) {
    const code = codeOf(output) || output;
    if (/\b(latest|stable|nightly)\b/i.test(code)) return { pass: false, reason: 'Uses floating version pin (latest/stable/nightly).' };
    if (/["'][\^~]\d/.test(code)) return { pass: false, reason: 'Uses caret/tilde version range instead of exact pin.' };
    const stages = new Set([...code.matchAll(/^\s*FROM\s+\S+(?:\s+\S+)*?\s+AS\s+(?<alias>\S+)/gim)].map(m => m.groups!.alias.toLowerCase()));
    const images = [...code.matchAll(/^\s*FROM\s+(?:--platform=\S+\s+)?(?<image>\S+)/gim)].map(m => m.groups!.image);
    const external = images.filter(i => i !== 'scratch' && !stages.has(i.toLowerCase()));
    if (external.length === 0) return { pass: true, reason: 'No base image found (N/A).' };
    const floating = external.filter(i => !/[@]sha256:/.test(i) && !/:[^:@\s]*\d+\.\d+\.\d+/.test(i));
    return floating.length === 0
      ? { pass: true, reason: 'Every base image pinned to an exact version.' }
      : { pass: false, reason: `Base image(s) without an exact x.y.z tag: ${floating.join(', ')}.` };
  },

  // ── Code Quality Family ────────────────────────────────────────────────

  /** Findings graded on the merge-gating scale (blocker/suggestion/question), not a risk ladder. */
  adversarial_severity(output: string) {
    if (!/\bblocker\b/i.test(output)) return { pass: false, reason: 'No finding classified as a merge blocker.' };
    return usesForeignSeverity(output)
      ? { pass: false, reason: 'Mixes in a critical/high/medium/low risk ladder instead of blocker/suggestion/question.' }
      : { pass: true, reason: 'Findings use blocker/suggestion/question severities.' };
  },

  /** Tests cover a success path AND a failure path. */
  testing_happy_sad(output: string) {
    const hasHappy = /\bhappy[\s-]*paths?\b|\bvalid[\s_-]*inputs?\b|==\s*datetime\(|\.(year|month|day)\s*==|\bassert(Equal|_equal)?\b[^\n]*==|toEqual\(/i.test(output);
    const hasSad = /\bsad[\s-]*paths?\b|\binvalid[\s_-]*inputs?\b|pytest\.raises|assertRaises|toThrow|\.rejects\b|\berror[\s_-]*cases?\b/i.test(output);
    if (hasHappy && hasSad) return { pass: true, reason: 'Covers both happy and sad paths.' };
    if (!hasHappy && !hasSad) return { pass: false, reason: 'Missing both happy and sad path test cases.' };
    return { pass: false, reason: `Missing ${!hasHappy ? 'happy' : 'sad'} path test cases.` };
  },

  // ── DevOps Family ──────────────────────────────────────────────────────

  /** Docker commands must verify daemon is running. */
  docker_daemon_check(output: string) {
    const hasDockerCmd = /\bdocker\s+(build|run|pull|push|compose|ps)\b/i.test(output);
    if (!hasDockerCmd) return { pass: true, reason: 'No docker command found (N/A).' };
    const hasCheck = /docker\s+info|docker\s+version|daemon|dockerd|colima\s+start/i.test(output);
    return hasCheck
      ? { pass: true, reason: 'Verifies Docker daemon before operations.' }
      : { pass: false, reason: 'Docker command without daemon verification (docker info).' };
  },

  /** Buildkite inspection AND retry go through the bk CLI — not REST/curl or GitHub tooling. */
  buildkite_bk_cli(output: string) {
    const code = codeOf(output) || output;
    if (/api\.buildkite\.com|\bgh\s+(run|checks?|workflow)\b/i.test(code)) {
      return { pass: false, reason: 'Uses REST/curl or gh instead of the bk CLI.' };
    }
    const inspects = /\bbk\s+(build\s+(view|list)|job\s+(log|list))\b/i.test(code);
    const retries = /\bbk\s+(job\s+retry|build\s+rebuild)\b/i.test(code);
    if (inspects && retries) return { pass: true, reason: 'Inspects and retries via the bk CLI.' };
    return { pass: false, reason: `Missing bk CLI ${!inspects ? 'build/job inspection' : 'job retry'} command.` };
  },

  /** Datadog writes go through pup, with --no-agent on a command handed to CI. */
  datadog_pup_cli(output: string) {
    // Whole reply: scripts arrive fenced, unfenced, or inside a tool-call body.
    const code = joinContinuations(output);
    const pupCreate = code.split('\n').filter(l => /\bpup\b/.test(l) && /\bmonitors?\s+create\b/i.test(l));
    if (pupCreate.length === 0) {
      return /api\.datadoghq|datadog-api-client|resource\s+"datadog_/i.test(code)
        ? { pass: false, reason: 'Creates the monitor via REST/SDK/Terraform instead of the pup CLI.' }
        : { pass: false, reason: 'No `pup monitors create` command.' };
    }
    return pupCreate.some(l => /--no-agent\b/.test(l))
      ? { pass: true, reason: 'pup monitors create runs with --no-agent for CI.' }
      : { pass: false, reason: 'pup command handed to CI lacks --no-agent (agent-mode envelope breaks jq).' };
  },

  // ── Communication Family ───────────────────────────────────────────────

  /** The Slack message itself (not the chat around it) is mrkdwn, not Markdown. */
  slack_mrkdwn(output: string) {
    const message = artifactOf(output);
    if (/\*\*[^*\n]+\*\*/.test(message)) return { pass: false, reason: 'Uses **bold** (Markdown) instead of *bold* (Slack mrkdwn).' };
    if (/\[[^\]\n]+\]\(https?:/.test(message)) return { pass: false, reason: 'Uses [label](url) instead of <url|label>.' };
    if (/^#{1,6}\s/m.test(message)) return { pass: false, reason: 'Uses a Markdown # heading.' };
    if (/\x7e\x7e[^\x7e\n]+\x7e\x7e/.test(message)) return { pass: false, reason: 'Uses double-tilde strikethrough instead of single-tilde.' };
    return { pass: true, reason: 'Message uses Slack mrkdwn only.' };
  },

  /** Mermaid diagrams must use <br/> not \\n for line breaks. */
  mermaid_linebreaks(output: string) {
    const mermaidBlocks = [...output.matchAll(/```mermaid\r?\n([\s\S]*?)```/g)].map(m => m[1]);
    if (mermaidBlocks.length === 0) return { pass: true, reason: 'No mermaid blocks (N/A).' };
    const content = mermaidBlocks.join('\n');
    const hasBackslashN = /\\n/.test(content);
    const hasStateDiagramLegacy = /\bstateDiagram\b(?!-v2)/i.test(content);
    if (hasBackslashN) return { pass: false, reason: 'Mermaid uses \\n instead of <br/> for line breaks.' };
    if (hasStateDiagramLegacy) return { pass: false, reason: 'Uses legacy stateDiagram instead of stateDiagram-v2.' };
    return { pass: true, reason: 'Mermaid syntax correct.' };
  },

  /** Markdown prose hard-wraps at 120 columns (tables, URLs, and code exempt). */
  markdown_wrap(output: string) {
    // A URL is never broken, so it counts as one column.
    const doc = /<parameter name="content">/.test(output) ? artifactOf(output) : output;
    const longLines = proseLinesOf(doc).filter(l =>
      !/^\s*\|/.test(l) && l.replace(/https?:\/\/\S+/g, 'U').length > MAX_LINE_COLUMNS);
    if (longLines.length === 0) return { pass: true, reason: `Prose lines within ${MAX_LINE_COLUMNS}-column wrap.` };
    return { pass: false, reason: `${longLines.length} prose line(s) exceed ${MAX_LINE_COLUMNS} columns.` };
  },

  // ── Utility Family ─────────────────────────────────────────────────────

  /** CalVer format must be YYYY.MM.DD-HHMMSS, never semver. */
  calver_format(output: string) {
    const hasSemver = /\b\d+\.\d+\.\d+\b/.test(output) && !/\b20\d{2}\.\d{2}\.\d{2}/.test(output);
    const hasCalver = /\b20\d{2}\.\d{2}\.\d{2}-\d{6}\b/.test(output);
    if (hasSemver && !hasCalver) return { pass: false, reason: 'Uses semver format instead of CalVer (YYYY.MM.DD-HHMMSS).' };
    if (hasCalver) return { pass: true, reason: 'Uses CalVer format.' };
    return { pass: true, reason: 'No version string found (N/A).' };
  },

  /** curl must use -sS not bare -s. */
  curl_flags(output: string) {
    const hasCurl = /\bcurl\b/i.test(output);
    if (!hasCurl) return { pass: true, reason: 'No curl command found (N/A).' };
    const hasSS = /-sS|--silent\s+--show-error/i.test(output);
    const hasBareS = /\bcurl\b/.test(output) && / -s[ \n]| -s$/.test(output) && !hasSS;
    if (hasBareS && !hasSS) return { pass: false, reason: 'curl uses bare -s instead of -sS.' };
    return { pass: true, reason: 'curl flags correct.' };
  },

  /** A tool quirk routes to learnings/skills/<tool>/<date>_<slug>.md, scrubbed of work-item identity. */
  learn_routing(output: string) {
    if (/\.claude\/memory/i.test(output)) return { pass: false, reason: 'Routes learning to agent memory.' };
    const routed = /learnings\/skills\/jq\/\d{4}-\d{2}-\d{2}_[a-z0-9]+(?:-[a-z0-9]+)*\.md\b/.test(output);
    if (!routed) return { pass: false, reason: 'Not written to learnings/skills/jq/<YYYY-MM-DD>_<slug>.md (tool quirk → tool skill).' };
    const contents = codeOf(output) || output;
    return /4821|\bjdoe\b|\bacme\b/i.test(contents)
      ? { pass: false, reason: 'Learning file keeps the PR number, reviewer handle, or org/repo name.' }
      : { pass: true, reason: 'Routed to the jq tool skill and scrubbed.' };
  },

  /** Retro entry: worked / could-be-better buckets, no timestamps or work-item identity. */
  retro_structured(output: string) {
    const entry = artifactOf(output, /what\s+worked|went\s+well/i);
    if (/\b\d{1,2}:\d{2}\b|\bUTC\b|#\d+|\bacme\//i.test(entry)) {
      return { pass: false, reason: 'Retro entry keeps a timestamp, PR number, or repo name.' };
    }
    const worked = /what\s+worked|went\s+well|\bkeep\s+doing\b/i.test(entry);
    const better = /could(?:'ve|\s+have)\s+been\s+better|didn'?t\s+go\s+well|went\s+wrong|to\s+improve|improvements?|\bgaps?\b|action\s+items?/i.test(entry);
    return worked && better
      ? { pass: true, reason: 'Two-bucket retro entry, scrubbed of timestamps and identifiers.' }
      : { pass: false, reason: 'Retro entry missing a what-worked or could-be-better section.' };
  },
};

export default function skillsGrader(output: string, context: GraderContext): GraderResult {
  const probe = context?.vars?.probe;
  const check: ProbeChecker | undefined = CHECKS[probe];
  if (!check) return { pass: true, score: 1, reason: `Unknown probe '${probe}', skipped` };
  const r = check(String(output || ''));
  return { pass: r.pass, score: r.pass ? 1 : 0, reason: r.reason };
}

export { CHECKS };
