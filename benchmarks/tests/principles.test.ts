/**
 * Unit test for the principle grader (graders/principles.ts).
 * Feeds known passing and failing outputs through each probe checker.
 * Runs without promptfoo or an API key — proves the grader distinguishes
 * the refined behavior from its absence.
 *
 * Run: node --experimental-strip-types benchmarks/tests/principles.test.ts
 */

import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import principleGrader, { CHECKS } from '../graders/principles.ts';
import type { GraderContext } from '../types.ts';

function check(probe: string, output: string) {
  return principleGrader(output, { vars: { probe } } as GraderContext);
}

// --- imperative: no hedging or pleasantries ---

describe('imperative', () => {
  it('passes when output uses direct commands', () => {
    const r = check('imperative', 'Add a null check before `.email`. Use `??` operator for the fallback.');
    assert.equal(r.pass, true);
    assert.equal(r.score, 1);
  });

  it('fails when output hedges', () => {
    const r = check('imperative', 'You might want to consider adding a null check. It might be worth looking at the email property.');
    assert.equal(r.pass, false);
    assert.equal(r.score, 0);
  });

  it('fails on pleasantries', () => {
    const r = check('imperative', 'Sure! Happy to help with that. The issue is a missing null check.');
    assert.equal(r.pass, false);
  });
});

// --- ladder: prioritized options, not equal-weight ---

describe('ladder', () => {
  it('passes with prioritized steps', () => {
    const r = check('ladder', 'First try the stdlib `json` module. If that fails, fall back to `orjson` for speed.');
    assert.equal(r.pass, true);
  });

  it('fails with equal-weight alternatives', () => {
    const r = check('ladder', 'You could either use `json` or `orjson`. Another option is `ujson`.');
    assert.equal(r.pass, false);
  });

  it('passes with single solution (no alternatives)', () => {
    const r = check('ladder', '```python\nimport json\ndata = json.loads(text)\n```');
    assert.equal(r.pass, true);
  });
});

// --- minimal: no unrequested abstraction ---

describe('minimal', () => {
  it('passes with simple code', () => {
    const r = check('minimal', '```python\ndef validate(email):\n    return "@" in email\n```');
    assert.equal(r.pass, true);
  });

  it('fails with factory pattern', () => {
    const r = check('minimal', '```python\nclass ValidatorFactory:\n    def create(self, type):\n        return self.registry[type]()\n```');
    assert.equal(r.pass, false);
  });

  it('fails with "for future" language', () => {
    const r = check('minimal', '```python\nclass BaseValidator:\n    """For future extension"""\n    pass\n```');
    assert.equal(r.pass, false);
  });
});

// --- nevercut: security/validation present ---

describe('nevercut', () => {
  it('passes when validation exists', () => {
    const r = check('nevercut', '```python\ndef handle(input):\n    if not validate(input):\n        raise ValueError("invalid")\n```');
    assert.equal(r.pass, true);
  });

  it('fails when no validation for trust-boundary task', () => {
    const r = check('nevercut', '```python\ndef handle(input):\n    return process(input)\n```');
    assert.equal(r.pass, false);
  });
});

// --- boundary: states what's out of scope ---

describe('boundary', () => {
  it('passes with boundary statement', () => {
    const r = check('boundary', '```python\ndef parse(s):\n    return int(s)\n```\nDoes not handle negative numbers or floats. Risk: raises on non-numeric input.');
    assert.equal(r.pass, true);
  });

  it('fails without any boundary statement', () => {
    const r = check('boundary', '```python\ndef parse(s):\n    return int(s)\n```\nConverts a string to integer.');
    assert.equal(r.pass, false);
  });
});

// --- concise: prose doesn't dwarf code ---

describe('concise', () => {
  it('passes with tight prose-to-code ratio', () => {
    const r = check('concise', 'Parse the duration string.\n\n```python\ndef parse(s):\n    return int(s)\n```');
    assert.equal(r.pass, true);
  });

  it('fails when prose dwarfs code', () => {
    const longProse = 'word '.repeat(200);
    const r = check('concise', `${longProse}\n\n\`\`\`python\nx = 1\n\`\`\``);
    assert.equal(r.pass, false);
  });
});

// --- reuse: stdlib before new deps ---

describe('reuse', () => {
  it('passes when using stdlib', () => {
    const r = check('reuse', '```python\nimport json\ndata = json.loads(text)\n```');
    assert.equal(r.pass, true);
  });

  it('fails when adding dep without considering stdlib', () => {
    const r = check('reuse', 'Run `pip install orjson` first.\n\n```python\nimport orjson\ndata = orjson.loads(text)\n```');
    assert.equal(r.pass, false);
  });

  it('passes when dep is justified with stdlib mention', () => {
    const r = check('reuse', 'The standard library `json` works but is 5x slower. `pip install orjson` for hot paths.\n\n```python\nimport orjson\n```');
    assert.equal(r.pass, true);
  });
});

// --- unknown probe skipped ---

describe('unknown probe', () => {
  it('skips gracefully', () => {
    const r = check('nonexistent', '```python\nprint(1)\n```');
    assert.equal(r.pass, true);
    assert.match(r.reason, /skipped/i);
  });
});
