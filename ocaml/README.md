# ltcodes for OCaml

Validate Lithuanian personal codes, company codes, VAT numbers and IBANs.

```ocaml
let () = assert (Ltcodes.is_personal_code "33309240064")
let () = assert (Ltcodes.is_company_code "123033512")
let () = assert (Ltcodes.is_vat_number "LT119511515")
let () = assert (Ltcodes.is_iban "LT121000011101001000")
```

Made by [KokybiskaSvetaine.lt](https://kokybiskasvetaine.lt/). Licence: MIT.
