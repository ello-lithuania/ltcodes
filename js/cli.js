#!/usr/bin/env node
'use strict';

const lt = require('./index.js');
const { version } = require('./package.json');

const USAGE = `usage: ltcodes CODE...

Checks Lithuanian personal codes (asmens kodas), company codes (juridinio
asmens kodas), VAT numbers (PVM moketojo kodas) and IBANs. Each code is
printed with what it is valid as, or "invalid".

Exit status: 0 when every code is valid, 1 when any is invalid,
2 on a usage error.`;

const LABEL = {
  personal: 'personal code',
  company: 'company code',
  vat: 'VAT number',
  iban: 'IBAN',
};

function describe(code) {
  return lt.kinds(code).map((k) => {
    const date = k === 'personal' && lt.birthDate(code);
    if (!date) return LABEL[k];
    const p = (n, w) => String(n).padStart(w, '0');
    return `personal code, born ${p(date.year, 4)}-${p(date.month, 2)}-${p(date.day, 2)}`;
  });
}

const args = process.argv.slice(2);
if (args.includes('-h') || args.includes('--help')) {
  console.log(USAGE);
  process.exit(0);
}
if (args.includes('-V') || args.includes('--version')) {
  console.log(`ltcodes ${version}`);
  process.exit(0);
}
if (args.length === 0) {
  console.error(USAGE);
  process.exit(2);
}
let allValid = true;
for (const code of args) {
  const k = describe(code);
  if (k.length === 0) allValid = false;
  console.log(`${code}: ${k.length ? `valid ${k.join(', ')}` : 'invalid'}`);
}
process.exit(allValid ? 0 : 1);
