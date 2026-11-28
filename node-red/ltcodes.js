'use strict';

const lt = require('@ellolt/ltcodes');

const KINDS = ['personal', 'company', 'vat', 'iban'];

module.exports = function (RED) {
  function LtCodesNode(config) {
    RED.nodes.createNode(this, config);
    const node = this;
    const property = config.property || 'payload';
    const kind = KINDS.includes(config.kind) ? config.kind : 'any';

    node.on('input', function (msg, send, done) {
      let value;
      try {
        value = RED.util.getMessageProperty(msg, property);
      } catch (err) {
        done(err);
        return;
      }
      const code = value === undefined || value === null ? '' : String(value).trim();
      const kinds = lt.kinds(code);
      const valid = kind === 'any' ? kinds.length > 0 : kinds.includes(kind);
      msg.ltcodes = {
        code,
        valid,
        kinds,
        birthDate: kinds.includes('personal') ? lt.birthDate(code) : null,
      };
      send(valid ? [msg, null] : [null, msg]);
      done();
    });
  }

  RED.nodes.registerType('ltcodes', LtCodesNode);
};
