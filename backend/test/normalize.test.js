import test from 'node:test';
import assert from 'node:assert/strict';
import { normalizeWord } from '../src/utils/normalize.js';

test('normalizeWord ignores case and sentence punctuation', () => {
  assert.equal(normalizeWord('Good,'), 'good');
  assert.equal(normalizeWord(' GOOD '), 'good');
});
