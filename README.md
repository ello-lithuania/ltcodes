# ltcodes

Validate Lithuanian personal codes, company codes, VAT numbers and IBANs. The same small library in four languages, with no dependencies.

| Language | Folder | Package |
|---|---|---|
| Rust | [`rust/`](rust) | `ltcodes` on crates.io |
| R | [`r/ltcodes/`](r/ltcodes) | `ltcodes` on CRAN |
| D | [`source/`](source) | `ltcodes` on the DUB registry |
| OCaml | [`ocaml/`](ocaml) | `ltcodes` on opam |

All four use the shared cases in [`test_vectors.json`](test_vectors.json).

## What is checked

- **Personal code** (*asmens kodas*): 11 digits, the first digit gives the century and sex, the next six the birth date, and the last one is a check digit. Codes that start with 9 carry no date, so only the check digit is tested.
- **Company code** (*juridinio asmens kodas*): 9 digits with a check digit. Tested against all 236,067 codes in the open data of the Register Centre (Registrų centras) on 9 November 2026: all of them pass.
- **VAT number** (*PVM mokėtojo kodas*): 9 or 12 digits, with or without the `LT` prefix.
- **IBAN**: 20 characters that start with `LT`, checked with the MOD-97 rule.

The check digit only proves that a code is well formed, not that it was issued to anyone.

## Who made it

Made and maintained by [KokybiskaSvetaine.lt](https://kokybiskasvetaine.lt/), a web development studio in Lithuania.

## Licence

MIT. See [LICENSE](LICENSE).
