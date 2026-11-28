'use strict';

/**
 * Validate Lithuanian personal codes, company codes, VAT numbers and IBANs.
 *
 * A valid check digit only proves that a code is well formed, not that it
 * was issued to anyone.
 */

function digits(s) {
  if (typeof s !== 'string' || !/^[0-9]+$/.test(s)) return null;
  return Array.from(s, Number);
}

// The shared check digit rule: weights 1 to 9, then 3 to 9, 1, 2 if the
// first pass gives 10.
function checkDigit(d) {
  const pass = (shift) =>
    d.reduce((sum, n, i) => sum + (1 + ((i + shift) % 9)) * n, 0) % 11;
  const first = pass(0);
  return first !== 10 ? first : pass(2) % 10;
}

function daysInMonth(year, month) {
  if ([1, 3, 5, 7, 8, 10, 12].includes(month)) return 31;
  if ([4, 6, 9, 11].includes(month)) return 30;
  if (month === 2) {
    return (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0 ? 29 : 28;
  }
  return 0;
}

const CENTURY = { 1: 1800, 2: 1800, 3: 1900, 4: 1900, 5: 2000, 6: 2000 };

/**
 * Returns the birth date in a personal code as { year, month, day }, or null
 * when the code has no valid date (codes that start with 9 carry none).
 */
function birthDate(code) {
  const d = digits(code);
  if (!d || d.length !== 11 || !CENTURY[d[0]]) return null;
  const year = CENTURY[d[0]] + d[1] * 10 + d[2];
  const month = d[3] * 10 + d[4];
  const day = d[5] * 10 + d[6];
  if (day < 1 || day > daysInMonth(year, month)) return null;
  return { year, month, day };
}

/** Tests a personal code (asmens kodas). */
function isPersonalCode(code) {
  const d = digits(code);
  if (!d || d.length !== 11) return false;
  if (d[0] !== 9 && !birthDate(code)) return false;
  return checkDigit(d.slice(0, 10)) === d[10];
}

/** Tests a company code (juridinio asmens kodas). */
function isCompanyCode(code) {
  const d = digits(code);
  return !!d && d.length === 9 && checkDigit(d.slice(0, 8)) === d[8];
}

function compact(s) {
  return typeof s === 'string' ? s.replace(/[\s-]/g, '').toUpperCase() : '';
}

/** Tests a VAT number (PVM mokėtojo kodas), with or without the LT prefix. */
function isVatNumber(code) {
  let c = compact(code);
  if (c.startsWith('LT')) c = c.slice(2);
  const d = digits(c);
  if (!d || (d.length !== 9 && d.length !== 12)) return false;
  const marker = d.length === 9 ? 7 : 10;
  return d[marker] === 1 && checkDigit(d.slice(0, -1)) === d[d.length - 1];
}

/** Tests a Lithuanian IBAN: 20 characters, the LT prefix and the MOD-97 rule. */
function isIban(code) {
  const c = compact(code);
  if (c.length !== 20 || !c.startsWith('LT')) return false;
  let rem = 0;
  for (const ch of c.slice(4) + c.slice(0, 4)) {
    if (!/^[0-9A-Z]$/.test(ch)) return false;
    const v = parseInt(ch, 36);
    rem = v > 9 ? (rem * 100 + v) % 97 : (rem * 10 + v) % 97;
  }
  return rem === 1;
}

/**
 * Lists what a code is valid as: any of 'personal', 'company', 'vat' and
 * 'iban'. The list is empty when the code is valid as nothing.
 */
function kinds(code) {
  const out = [];
  if (isPersonalCode(code)) out.push('personal');
  if (isCompanyCode(code)) out.push('company');
  if (isVatNumber(code)) out.push('vat');
  if (isIban(code)) out.push('iban');
  return out;
}

module.exports = {
  birthDate,
  isPersonalCode,
  isCompanyCode,
  isVatNumber,
  isIban,
  kinds,
};
