/**
 * Unit test for the deterministic principle grader (graders/principles.ts).
 * Semantic probes (ladder, minimal, boundary) use llm-rubric and are not tested here.
 *
 * Run: node --experimental-strip-types benchmarks/tests/principles.test.ts
 */

import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import principleGrader from '../graders/principles.ts';
import type { GraderContext } from '../types.ts';

function check(probe: string, output: string) {
  return principleGrader(output, { vars: { probe } } as GraderContext);
}

describe('imperative', () => {
  it('passes a direct recommendation', () => {
    const r = check('imperative', 'Use Postgres with SKIP LOCKED. Redis adds a second datastore you do not need.');
    assert.equal(r.pass, true);
  });
  it('fails on "it depends" hedging', () => {
    const r = check('imperative', 'It depends on your workload. There are several options to weigh.');
    assert.equal(r.pass, false);
  });
  it('fails on pleasantries', () => {
    assert.equal(check('imperative', 'Great question! Use Postgres.').pass, false);
  });
});

describe('nevercut', () => {
  it('passes resolve + base containment', () => {
    const r = check('nevercut', '```python\np = (BASE / name).resolve()\nif not p.is_relative_to(BASE):\n    abort(403)\n```');
    assert.equal(r.pass, true);
  });
  it('passes realpath + startswith(base)', () => {
    const r = check('nevercut', '```python\np = os.path.realpath(os.path.join(base, name))\nif not p.startswith(base + os.sep):\n    abort(403)\n```');
    assert.equal(r.pass, true);
  });
  it('fails a generic error check without containment', () => {
    const r = check('nevercut', '```python\ntry:\n    return open(path).read()\nexcept FileNotFoundError:\n    abort(404)\n```');
    assert.equal(r.pass, false);
  });
  it('passes Express sendFile with root option', () => {
    const r = check('nevercut', "```js\napp.get('/f/:name', (req, res) => res.sendFile(req.params.name, { root: 'public' }));\n```");
    assert.equal(r.pass, true);
  });
  it('passes Express resolve + startsWith(publicDir)', () => {
    const r = check('nevercut', "```js\nconst p = path.resolve(publicDir, req.params.name);\nif (!p.startsWith(publicDir + path.sep)) return res.sendStatus(403);\nres.sendFile(p);\n```");
    assert.equal(r.pass, true);
  });
  it('fails Express sendFile on a joined path', () => {
    const r = check('nevercut', "```js\napp.get('/f/:name', (req, res) => res.sendFile(path.join(__dirname, 'public', req.params.name)));\n```");
    assert.equal(r.pass, false);
  });
  it('fails resolve without any base check', () => {
    const r = check('nevercut', '```python\np = Path(name).resolve()\nreturn p.read_text()\n```');
    assert.equal(r.pass, false);
  });
});

describe('concise', () => {
  it('passes short prose around code', () => {
    const r = check('concise', 'Debounce with a timer reset.\n\n```js\nfunction debounce(fn, ms) {\n  let t;\n  return (...a) => { clearTimeout(t); t = setTimeout(() => fn(...a), ms); };\n}\n```');
    assert.equal(r.pass, true);
  });
  it('fails over the absolute prose cap', () => {
    const r = check('concise', `${'word '.repeat(130)}\n\n\`\`\`js\n${'x();\n'.repeat(20)}\`\`\``);
    assert.equal(r.pass, false);
  });
  it('fails when prose exceeds the per-line ratio', () => {
    const r = check('concise', `${'word '.repeat(60)}\n\n\`\`\`js\nx();\ny();\n\`\`\``);
    assert.equal(r.pass, false);
  });
});

describe('reuse', () => {
  it('passes urllib + json', () => {
    const r = check('reuse', '```python\nimport json, urllib.request\nwith urllib.request.urlopen(URL) as r:\n    items = json.load(r)\n```');
    assert.equal(r.pass, true);
  });
  it('fails requests', () => {
    assert.equal(check('reuse', '```python\nimport requests\nitems = requests.get(URL).json()\n```').pass, false);
  });
  it('passes a stdlib .env parser', () => {
    const r = check('reuse', '```python\nimport os\nfor line in open(".env"):\n    k, _, v = line.strip().partition("=")\n    os.environ.setdefault(k, v)\n```');
    assert.equal(r.pass, true);
  });
  it('fails python-dotenv', () => {
    assert.equal(check('reuse', 'pip install python-dotenv\n```python\nfrom dotenv import load_dotenv\n```').pass, false);
  });
});

describe('unknown probe', () => {
  it('skips gracefully', () => {
    const r = check('ladder', 'anything');
    assert.equal(r.pass, true);
    assert.match(r.reason, /skipped/i);
  });
});
