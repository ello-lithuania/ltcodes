# ltcodes

Validate Lithuanian personal codes, company codes, VAT numbers and IBANs in JavaScript. No dependencies, works in Node.js and with bundlers (CommonJS, with TypeScript types).

```
npm install ltcodes
```

```js
const lt = require('ltcodes');

lt.isPersonalCode('33309240064');     // true
lt.birthDate('33309240064');          // { year: 1933, month: 9, day: 24 }
lt.isCompanyCode('123033512');        // true
lt.isVatNumber('LT119511515');        // true
lt.isIban('LT12 1000 0111 0100 1000'); // true
lt.kinds('123033512');                // ['company', 'vat']
```

`kinds()` lists everything a code is valid as, which helps when a form has one field for "company code or VAT number".

## Command line

```
$ npx ltcodes 33309240064 123033512 "LT12 1000 0111 0100 1000" 33309240164
33309240064: valid personal code, born 1933-09-24
123033512: valid company code, VAT number
LT12 1000 0111 0100 1000: valid IBAN
33309240164: invalid
```

The exit status is 0 when every code is valid, 1 when any is invalid.

## What is checked

- **Personal code** (*asmens kodas*): 11 digits, the first digit gives the century and sex, the next six the birth date, and the last one is a check digit. Codes that start with 9 carry no date, so only the check digit is tested.
- **Company code** (*juridinio asmens kodas*): 9 digits with a check digit.
- **VAT number** (*PVM mokėtojo kodas*): 9 or 12 digits, with or without the `LT` prefix.
- **IBAN**: 20 characters that start with `LT`, checked with the MOD-97 rule.

The check digit only proves that a code is well formed, not that it was issued to anyone.

The same rules are implemented in Rust, R, D, OCaml, Clojure, Haxe and other languages in the [ltcodes repository](https://github.com/ello-lithuania/ltcodes), and all versions pass the same shared test cases.

Made by [KokybiskaSvetaine.lt](https://kokybiskasvetaine.lt/). Licence: MIT.
