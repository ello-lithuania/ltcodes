'use strict';

const assert = require('node:assert');
const path = require('node:path');
const helper = require('node-red-node-test-helper');
const ltNode = require('../ltcodes.js');

const vectors = require(path.join(__dirname, '..', '..', 'test_vectors.json'));

helper.init(require.resolve('node-red'));

function flow(kind, property) {
  return [
    { id: 'n1', type: 'ltcodes', kind, property: property || 'payload', wires: [['ok'], ['bad']] },
    { id: 'ok', type: 'helper' },
    { id: 'bad', type: 'helper' },
  ];
}

// Loads the flow and returns send(msg), which resolves with the output used.
async function start(kind, property) {
  await helper.load(ltNode, flow(kind, property));
  let pending = null;
  helper.getNode('ok').on('input', (msg) => pending({ valid: true, msg }));
  helper.getNode('bad').on('input', (msg) => pending({ valid: false, msg }));
  return (msg) =>
    new Promise((resolve) => {
      pending = resolve;
      helper.getNode('n1').receive(msg);
    });
}

describe('ltcodes node', function () {
  beforeEach(function (done) {
    helper.startServer(done);
  });
  afterEach(async function () {
    await helper.unload();
    await helper.stopServer();
  });

  for (const kind of ['personal', 'company', 'vat', 'iban']) {
    it(`${kind}: shared test vectors`, async function () {
      const send = await start(kind);
      for (const code of vectors[kind].valid) {
        assert.strictEqual((await send({ payload: code })).valid, true, code);
      }
      for (const code of vectors[kind].invalid) {
        assert.strictEqual((await send({ payload: code })).valid, false, code);
      }
    });
  }

  it('any kind: reports every match and the birth date', async function () {
    const send = await start('any');
    const company = await send({ payload: ' 123033512 ' });
    assert.strictEqual(company.valid, true);
    assert.deepStrictEqual(company.msg.ltcodes.kinds, ['company', 'vat']);
    const person = await send({ payload: 33309240064 });
    assert.deepStrictEqual(person.msg.ltcodes.birthDate, { year: 1933, month: 9, day: 24 });
    const missing = await send({});
    assert.strictEqual(missing.valid, false);
  });

  it('reads the code from another property', async function () {
    const send = await start('iban', 'form.iban');
    const r = await send({ form: { iban: 'LT12 1000 0111 0100 1000' } });
    assert.strictEqual(r.valid, true);
    assert.strictEqual(r.msg.ltcodes.code, 'LT12 1000 0111 0100 1000');
  });
});
