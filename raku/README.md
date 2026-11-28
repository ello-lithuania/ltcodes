# LTCodes

Validate Lithuanian personal codes, company codes, VAT numbers and IBANs in Raku. No dependencies.

```
zef install LTCodes
```

```raku
use LTCodes;

say is-personal-code('33309240064');      # True
say birth-date('33309240064');            # 1933-09-24
say is-company-code('123033512');         # True
say is-vat-number('LT119511515');         # True
say is-iban('LT12 1000 0111 0100 1000');  # True
say code-kinds('123033512');              # (company vat)
```

## What is checked

- **Personal code** (*asmens kodas*): 11 digits, the first digit gives the century and sex, the next six the birth date, and the last one is a check digit. Codes that start with 9 carry no date, so only the check digit is tested.
- **Company code** (*juridinio asmens kodas*): 9 digits with a check digit.
- **VAT number** (*PVM mokėtojo kodas*): 9 or 12 digits, with or without the `LT` prefix.
- **IBAN**: 20 characters that start with `LT`, checked with the MOD-97 rule.

The check digit only proves that a code is well formed, not that it was issued to anyone.

The same rules are implemented in Rust, JavaScript, R, D, OCaml and other languages in the [ltcodes repository](https://github.com/ello-lithuania/ltcodes), and all versions pass the same shared test cases.

Made by [KokybiskaSvetaine.lt](https://kokybiskasvetaine.lt/). Licence: MIT.
