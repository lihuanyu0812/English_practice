import test from 'node:test';
import assert from 'node:assert/strict';
import { submitAnswer } from '../src/services/practiceService.js';

test('practice service module exposes submitAnswer', () => {
  assert.equal(typeof submitAnswer, 'function');
});
