/**
 * Skill-specific grader: does each skill family produce its intended behaviors?
 *
 * One check per probe (vars.probe), each targeting a concrete rule from the
 * skill's SKILL.md. Heuristic graders proven by tests/skills.test.ts
 * (RED/GREEN, no API key needed).
 *
 * Metric: `skill_behavior` (1 = behavior present, 0 = absent).
 */

import type { GraderResult, GraderContext, ProbeChecker, ProbeCheckers } from '../types.ts';

function lower(text: string): string {
  return text.toLowerCase();
}

function proseOf(text: string): string {
  return text.replace(/```[\s\S]*?```/g, ' ').replace(/\s+/g, ' ').trim();
}

function codeOf(text: string): string {
  const blocks = [...text.matchAll(/```[a-zA-Z0-9_+-]*\r?\n([\s\S]*?)```/g)].map(m => m[1]);
  return blocks.length ? blocks.join('\n') : '';
}

// ── PR Family ──────────────────────────────────────────────────────────────

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

  /** PR review must open with a verdict, not praise. */
  pr_review_verdict(output: string) {
    const firstLine = output.split('\n').find(l => l.trim())?.trim() || '';
    const startsWithPraise = /^(solid|well[- ]scoped|great|nice|good|excellent|awesome|beautiful|clean|lovely)/i.test(firstLine);
    const hasVerdict = /\b(LGTM|approv(e|ing|ed)|request(ing)?\s+changes?|block(ing|er)?|concern|changes?\s+requested)\b/i.test(firstLine);
    if (startsWithPraise) return { pass: false, reason: `Review opens with praise adjective: "${firstLine.slice(0, 50)}"` };
    if (hasVerdict) return { pass: true, reason: 'Review opens with verdict state.' };
    return { pass: true, reason: 'First line is neutral (no praise detected).' };
  },

  /** PR review comments must carry severity prefix. */
  pr_review_severity(output: string) {
    const commentLines = output.split('\n').filter(l => /^\s*(concern|suggestion|question|praise|blocker|nit)\s*:/i.test(l));
    const totalCommentish = output.split('\n').filter(l => /^\s*[-*]\s+\S/.test(l) || /^\s*(concern|suggestion|question|praise|blocker|nit|issue|problem|bug|note)\s*:/i.test(l));
    if (totalCommentish.length === 0) return { pass: true, reason: 'No review comments found (N/A).' };
    const ratio = commentLines.length / Math.max(totalCommentish.length, 1);
    return ratio >= 0.5
      ? { pass: true, reason: `${commentLines.length}/${totalCommentish.length} comments have severity prefix.` }
      : { pass: false, reason: `Only ${commentLines.length}/${totalCommentish.length} comments have severity prefix (concern:/suggestion:/question:/praise:).` };
  },

  /** PR merge must retarget stacked children. */
  pr_merge_retarget(output: string) {
    const t = lower(output);
    const mentionsMerge = /\bmerge\b/.test(t);
    const mentionsStack = /\bstack(ed)?\b/.test(t);
    if (!mentionsMerge || !mentionsStack) return { pass: true, reason: 'Not a stacked-PR merge context (N/A).' };
    const hasRetarget = /gh\s+pr\s+edit.*--base/i.test(output) || /retarget/i.test(output);
    return hasRetarget
      ? { pass: true, reason: 'Retargets stacked children before merge.' }
      : { pass: false, reason: 'Stacked PR merge missing retarget step (gh pr edit --base).' };
  },

  /** PR resolve must not start replies with pleasantries. */
  pr_resolve_no_pleasantries(output: string) {
    const replyBlocks = output.split(/(?:^|\n)(?:reply|response|comment)\s*:/im);
    for (const block of replyBlocks.slice(1)) {
      const firstLine = block.split('\n').find(l => l.trim())?.trim() || '';
      if (/^(good catch|great|thanks|nice|well spotted|good point)/i.test(firstLine)) {
        return { pass: false, reason: `Reply starts with pleasantry: "${firstLine.slice(0, 50)}"` };
      }
    }
    const allLines = output.split('\n');
    for (const line of allLines) {
      if (/^>\s/.test(line)) continue;
      const t = line.trim();
      if (t && /^(good catch|thanks for|great catch|nice catch|well spotted|good point)/i.test(t)) {
        return { pass: false, reason: `Line starts with pleasantry: "${t.slice(0, 50)}"` };
      }
    }
    return { pass: true, reason: 'No pleasantry-led replies detected.' };
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

  /** Workflow must follow phase ordering. */
  workflow_phases(output: string) {
    // Order by section headings, not first mention: a Plan section that says
    // "run tests" must not read as Test-before-Implement.
    const headings = output.split('\n')
      .filter(l => /^\s*(#{1,6}\s|\*\*|phase\s*\d|\d+[.)]\s)/i.test(l))
      .join('\n').toLowerCase();
    const t = headings.length ? headings : lower(output);
    const phases = ['plan', 'implement', 'test', 'review'];
    const positions = phases.map(p => t.indexOf(p)).filter(i => i >= 0);
    if (positions.length < 2) return { pass: true, reason: 'Fewer than 2 phases mentioned (N/A).' };
    const isSorted = positions.every((v, i) => i === 0 || v >= positions[i - 1]);
    return isSorted
      ? { pass: true, reason: 'Phases appear in correct order.' }
      : { pass: false, reason: 'Phases appear out of order (must be Plan → Implement → Test → Review).' };
  },

  /** Workflow must not use `latest`/`stable`/`nightly` version pins. */
  workflow_version_pins(output: string) {
    const code = codeOf(output) || output;
    const badPins = /\b(latest|stable|nightly)\b/i;
    const caretTilde = /["'][\^~]\d/;
    if (badPins.test(code)) return { pass: false, reason: 'Uses floating version pin (latest/stable/nightly).' };
    if (caretTilde.test(code)) return { pass: false, reason: 'Uses caret/tilde version range instead of exact pin.' };
    return { pass: true, reason: 'No floating version pins detected.' };
  },

  /** Plan must produce numbered steps with parallelism markers. */
  plan_numbered_steps(output: string) {
    const numbered = output.match(/^\s*\d+[.)]\s/gm);
    if (!numbered || numbered.length < 2) {
      return { pass: false, reason: `Found ${numbered?.length ?? 0} numbered steps, need at least 2.` };
    }
    const hasMarker = /\[AGENT-READY\]|\[AGENT-GUIDED\]|\[HUMAN-IN-LOOP\]/i.test(output);
    return hasMarker
      ? { pass: true, reason: `${numbered.length} numbered steps with parallelism markers.` }
      : { pass: false, reason: `${numbered.length} numbered steps but missing parallelism markers ([AGENT-READY]/[AGENT-GUIDED]/[HUMAN-IN-LOOP]).` };
  },

  // ── Code Quality Family ────────────────────────────────────────────────

  /** Adversarial review findings must have severity. */
  adversarial_severity(output: string) {
    const hasFinding = /\b(finding|issue|problem|defect)\b/i.test(output);
    if (!hasFinding) return { pass: true, reason: 'No findings (N/A).' };
    const hasSeverity = /\b(blocker|suggestion|question|critical|major|minor|nit)\b/i.test(output);
    return hasSeverity
      ? { pass: true, reason: 'Findings include severity levels.' }
      : { pass: false, reason: 'Findings missing severity classification (blocker/suggestion/question).' };
  },

  /** Testing skeleton must include happy AND sad paths. */
  testing_happy_sad(output: string) {
    const t = lower(output);
    const hasHappy = /\b(happy\s*path|success\s*case|valid\s*input|positive\s*test|should\s+succeed|should\s+return)\b/.test(t);
    const hasSad = /\b(sad\s*path|error\s*case|invalid\s*input|negative\s*test|should\s+fail|should\s+raise|should\s+throw|edge\s*case|boundary)\b/.test(t);
    if (hasHappy && hasSad) return { pass: true, reason: 'Covers both happy and sad paths.' };
    if (!hasHappy && !hasSad) return { pass: false, reason: 'Missing both happy and sad path test cases.' };
    return { pass: false, reason: `Missing ${!hasHappy ? 'happy' : 'sad'} path test cases.` };
  },

  /** Design review findings must be severity-ranked. */
  design_review_ranked(output: string) {
    const hasFinding = /\b(finding|issue|concern|problem)\b/i.test(output);
    if (!hasFinding) return { pass: true, reason: 'No findings (N/A).' };
    const hasSeverity = /\b(critical|high|medium|low|blocker|major|minor|p[0-3])\b/i.test(output);
    const hasHeuristic = /\b(heuristic|principle|violation|rule|guideline|pattern)\b/i.test(output);
    if (hasSeverity) return { pass: true, reason: 'Findings are severity-ranked.' };
    if (hasHeuristic) return { pass: true, reason: 'Findings reference heuristics/principles.' };
    return { pass: false, reason: 'Design review findings missing severity ranking.' };
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

  /** Buildkite uses bk CLI, not GitHub tools for CI. */
  buildkite_bk_cli(output: string) {
    const t = lower(output);
    const hasBuildkite = /buildkite|bk\s/i.test(output);
    if (!hasBuildkite) return { pass: true, reason: 'No Buildkite context (N/A).' };
    const usesBk = /\bbk\s+(build|job|agent|pipeline)\b/i.test(output);
    const usesGh = /\bgh\s+(run|check|workflow)\b/i.test(output);
    if (usesBk && !usesGh) return { pass: true, reason: 'Uses bk CLI for CI status.' };
    if (usesGh) return { pass: false, reason: 'Uses gh CLI instead of bk CLI for Buildkite CI.' };
    return { pass: true, reason: 'Buildkite mentioned without CLI usage (N/A).' };
  },

  /** Datadog uses pup CLI, not raw curl. */
  datadog_pup_cli(output: string) {
    const t = lower(output);
    const hasDatadog = /datadog|pup\s/i.test(output);
    if (!hasDatadog) return { pass: true, reason: 'No Datadog context (N/A).' };
    const usesPup = /\bpup\s+(dash|monitor|slo|notebook|auth)\b/i.test(output);
    const usesCurl = /curl.*api\.datadoghq/i.test(output);
    if (usesPup) return { pass: true, reason: 'Uses pup CLI for Datadog.' };
    if (usesCurl) return { pass: false, reason: 'Uses raw curl instead of pup CLI for Datadog.' };
    return { pass: true, reason: 'Datadog mentioned without API call (N/A).' };
  },

  // ── Communication Family ───────────────────────────────────────────────

  /** Slack must use mrkdwn format, not standard Markdown. */
  slack_mrkdwn(output: string) {
    const hasSlack = /slack|channel|message/i.test(output);
    if (!hasSlack) return { pass: true, reason: 'No Slack context (N/A).' };
    const usesMarkdown = /\*\*[^*]+\*\*/i.test(output);
    const usesMrkdwn = /(?<!\*)\*[^*\n]+\*(?!\*)/i.test(output);
    if (usesMarkdown) return { pass: false, reason: 'Uses **bold** (Markdown) instead of *bold* (Slack mrkdwn).' };
    return { pass: true, reason: 'No standard Markdown bold detected.' };
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

  /** Markdown must hard-wrap at 120 columns. */
  markdown_wrap(output: string) {
    const prose = proseOf(output);
    const lines = prose.split('\n').filter(l => l.trim());
    const longLines = lines.filter(l => l.length > 130 && !/^https?:\/\//.test(l.trim()) && !/^\|/.test(l.trim()));
    if (longLines.length === 0) return { pass: true, reason: 'Prose lines within 120-column wrap.' };
    return { pass: false, reason: `${longLines.length} prose line(s) exceed 120 columns.` };
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

  /** Learn output must route to learnings/, not memory/. */
  learn_routing(output: string) {
    const t = lower(output);
    const hasLearning = /learning|learned/i.test(output);
    if (!hasLearning) return { pass: true, reason: 'No learning context (N/A).' };
    const routesToMemory = /\.claude\/memory/i.test(output);
    const routesToLearnings = /learnings\//i.test(output);
    if (routesToMemory) return { pass: false, reason: 'Routes learning to memory/ instead of learnings/.' };
    if (routesToLearnings) return { pass: true, reason: 'Routes learning to learnings/ directory.' };
    return { pass: true, reason: 'Learning mentioned without file routing (N/A).' };
  },

  /** Retro must capture structured learnings. */
  retro_structured(output: string) {
    const t = lower(output);
    const hasRetro = /retro|retrospective/i.test(output);
    if (!hasRetro) return { pass: true, reason: 'No retro context (N/A).' };
    const hasStructure = /\b(what went well|what didn't|improve|learning|action item|takeaway|keep doing|stop doing|start doing)\b/i.test(output);
    return hasStructure
      ? { pass: true, reason: 'Retrospective has structured sections.' }
      : { pass: false, reason: 'Retrospective missing structured sections (what went well/didn\'t/improve).' };
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
