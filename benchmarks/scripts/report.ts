/**
 * Report on promptfoo eval output.
 *
 *   calibrate <results.json>        Per probe: does the skill separate from baseline?
 *                                   KEEP = baseline ≤ 50% and with-skills ≥ 80%; else REDESIGN.
 *   compare <old.json> <new.json>   With-skills pass rate old vs new per probe. A drop counts as a
 *                                   regression only when it exceeds the noise floor: the baseline
 *                                   arm's own run-to-run spread (identical across runs), min 20pp.
 *                                   Exits 1 on any regression.
 *
 * A new run may skip the baseline arm (--filter-prompts with-skills); compare then reuses the
 * baseline from the other file.
 *
 * Run: node --experimental-strip-types benchmarks/scripts/report.ts <command> <files...>
 */

import { readFileSync } from 'node:fs';

const GATE_METRICS = new Set(['principle', 'skill_behavior']);
const BASELINE = 'baseline (no skill)';
const WITH_SKILLS = 'with-skills';
const KEEP_BASELINE_MAX = 0.5;
const KEEP_SKILL_MIN = 0.8;
const MIN_NOISE_FLOOR = 0.2;

interface Tally { pass: number; total: number }
type Rates = Map<string, Tally>; // key: `${arm}\t${probe}`

interface PromptfooRow {
  prompt?: { label?: string };
  vars?: Record<string, string>;
  gradingResult?: { componentResults?: { pass?: boolean; assertion?: { metric?: string } }[] };
}

function load(path: string): Rates {
  const rows: PromptfooRow[] = JSON.parse(readFileSync(path, 'utf8')).results.results;
  const rates: Rates = new Map();
  for (const row of rows) {
    const gate = (row.gradingResult?.componentResults ?? [])
      .filter(c => GATE_METRICS.has(c.assertion?.metric ?? ''));
    if (!gate.length) continue;
    const key = `${row.prompt?.label ?? '?'}\t${row.vars?.probe ?? '?'}`;
    const t = rates.get(key) ?? { pass: 0, total: 0 };
    t.pass += gate.every(c => c.pass) ? 1 : 0;
    t.total += 1;
    rates.set(key, t);
  }
  return rates;
}

const rate = (t?: Tally): number | undefined => (t && t.total ? t.pass / t.total : undefined);
const fmt = (t?: Tally): string => (t && t.total ? `${t.pass}/${t.total}` : '-');
const probesOf = (...all: Rates[]): string[] =>
  [...new Set(all.flatMap(r => [...r.keys()].map(k => k.split('\t')[1])))].sort();
const get = (r: Rates, arm: string, probe: string) => r.get(`${arm}\t${probe}`);

function calibrate(path: string): number {
  const r = load(path);
  console.log(`${'probe'.padEnd(28)} ${'baseline'.padStart(9)} ${'skill'.padStart(9)}  verdict`);
  for (const probe of probesOf(r)) {
    const b = get(r, BASELINE, probe), s = get(r, WITH_SKILLS, probe);
    const br = rate(b), sr = rate(s);
    let verdict = 'KEEP';
    if (br === undefined || sr === undefined) verdict = 'INCOMPLETE';
    else if (br > KEEP_BASELINE_MAX) verdict = 'REDESIGN (baseline passes; scenario too easy)';
    else if (sr < KEEP_SKILL_MIN) verdict = 'REDESIGN (skill does not produce the behavior)';
    console.log(`${probe.padEnd(28)} ${fmt(b).padStart(9)} ${fmt(s).padStart(9)}  ${verdict}`);
  }
  return 0;
}

function compare(oldPath: string, newPath: string): number {
  const o = load(oldPath), n = load(newPath);
  console.log(`${'probe'.padEnd(28)} ${'baseline'.padStart(9)} ${'old'.padStart(7)} ${'new'.padStart(7)}  delta  floor`);
  const regressed: string[] = [];
  for (const probe of probesOf(o, n)) {
    const bo = get(o, BASELINE, probe), bn = get(n, BASELINE, probe);
    const so = rate(get(o, WITH_SKILLS, probe)), sn = rate(get(n, WITH_SKILLS, probe));
    const spread = rate(bo) !== undefined && rate(bn) !== undefined ? Math.abs(rate(bo)! - rate(bn)!) : 0;
    const floor = Math.max(spread, MIN_NOISE_FLOOR);
    const delta = so !== undefined && sn !== undefined ? sn - so : undefined;
    const flag = delta !== undefined && delta < -floor ? '  ⚠ REGRESSION' : '';
    if (flag) regressed.push(probe);
    const pooledBaseline = fmt(bo && bn ? { pass: bo.pass + bn.pass, total: bo.total + bn.total } : bo ?? bn);
    console.log(
      `${probe.padEnd(28)} ${pooledBaseline.padStart(9)} ${fmt(get(o, WITH_SKILLS, probe)).padStart(7)} ` +
      `${fmt(get(n, WITH_SKILLS, probe)).padStart(7)}  ${delta === undefined ? '  -  ' : (delta >= 0 ? '+' : '') + delta.toFixed(2)}  ${floor.toFixed(2)}${flag}`,
    );
  }
  console.log(`regressed: ${regressed.join(', ') || 'none'}`);
  return regressed.length ? 1 : 0;
}

const [command, ...files] = process.argv.slice(2);
if (command === 'calibrate' && files.length === 1) process.exit(calibrate(files[0]));
if (command === 'compare' && files.length === 2) process.exit(compare(files[0], files[1]));
console.error('usage: report.ts calibrate <results.json> | compare <old.json> <new.json>');
process.exit(2);
