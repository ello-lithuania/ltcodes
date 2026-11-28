'use strict';

const test = require('node:test');
const assert = require('node:assert');
const path = require('node:path');
const { execFileSync } = require('node:child_process');
const lt = require('..');

const vectors = require(path.join(__dirname, '..', '..', 'test_vectors.json'));
const CHECK = {
  personal: lt.isPersonalCode,
  company: lt.isCompanyCode,
  vat: lt.isVatNumber,
  iban: lt.isIban,
};

for (const [kind, fn] of Object.entries(CHECK)) {
  test(`${kind}: shared test vectors`, () => {
    for (const code of vectors[kind].valid) assert.ok(fn(code), code);
    for (const code of vectors[kind].invalid) assert.ok(!fn(code), code);
  });
}

test('birth date', () => {
  assert.deepStrictEqual(lt.birthDate('33309240064'), { year: 1933, month: 9, day: 24 });
  assert.strictEqual(lt.birthDate('33313240064'), null);
  assert.strictEqual(lt.birthDate('90000000009'), null);
});

test('non-string input is invalid', () => {
  for (const v of [undefined, null, 33309240064, {}]) {
    assert.deepStrictEqual(lt.kinds(v), []);
  }
});

test('command line', () => {
  const cli = path.join(__dirname, '..', 'cli.js');
  const out = execFileSync(process.execPath, [cli, '33309240064', 'LT12 1000 0111 0100 1000'], {
    encoding: 'utf8',
  });
  assert.strictEqual(
    out,
    '33309240064: valid personal code, born 1933-09-24\nLT12 1000 0111 0100 1000: valid IBAN\n',
  );
  assert.throws(() => execFileSync(process.execPath, [cli, '33309240164'], { stdio: 'pipe' }), (e) => e.status === 1);
});
