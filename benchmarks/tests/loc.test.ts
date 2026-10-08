/**
 * Unit test for the LOC grader (graders/loc.ts).
 * Run: node --experimental-strip-types benchmarks/tests/loc.test.ts
 */

import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import locGrader from '../graders/loc.ts';

describe('loc grader', () => {
  it('counts fenced code lines', () => {
    const r = locGrader('```js\nconst a = 1;\nconst b = 2;\n```');
    assert.equal(r.score, 2);
    assert.equal(r.pass, true);
  });

  it('strips line comments', () => {
    const r = locGrader('```js\n// header\nconst x = 1;\n```');
    assert.equal(r.score, 1);
  });

  it('strips block comments', () => {
    const r = locGrader('```js\nfunction f() {\n  /* explain\n     the rest */\n  return 1;\n}\n```');
    assert.equal(r.score, 3);
  });

  it('handles bare unfenced code', () => {
    const r = locGrader('const a = 1;\nconst b = 2;');
    assert.equal(r.score, 2);
  });

  it('handles empty output', () => {
    const r = locGrader('');
    assert.equal(r.score, 0);
  });

  it('handles CRLF fences', () => {
    const r = locGrader('```js\r\nconst a = 1;\r\nconst b = 2;\r\n```');
    assert.equal(r.score, 2);
  });
});
