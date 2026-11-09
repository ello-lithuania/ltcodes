# ltcodes

Validate Lithuanian personal codes, company codes, VAT numbers and IBANs. No dependencies.

```rust
assert!(ltcodes::is_personal_code("33309240064"));
assert_eq!(ltcodes::birth_date("33309240064"), Some((1933, 9, 24)));
assert!(ltcodes::is_company_code("123033512"));
assert!(ltcodes::is_vat_number("LT119511515"));
assert!(ltcodes::is_iban("LT12 1000 0111 0100 1000"));
```

## What is checked

- **Personal code** (*asmens kodas*): 11 digits, the first digit gives the century and sex, the next six the birth date, and the last one is a check digit. Codes that start with 9 carry no date, so only the check digit is tested.
- **Company code** (*juridinio asmens kodas*): 9 digits with a check digit. Tested against all 236,067 codes in the open data of the Register Centre (Registrų centras) on 9 November 2026: all of them pass.
- **VAT number** (*PVM mokėtojo kodas*): 9 or 12 digits, with or without the `LT` prefix.
- **IBAN**: 20 characters that start with `LT`, checked with the MOD-97 rule.

The check digit only proves that a code is well formed, not that it was issued to anyone.

Made by [KokybiskaSvetaine.lt](https://kokybiskasvetaine.lt/). Licence: MIT.
