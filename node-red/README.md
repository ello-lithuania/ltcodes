# node-red-contrib-ltcodes

A [Node-RED](https://nodered.org/) node that checks Lithuanian personal codes (*asmens kodas*), company codes (*įmonės kodas*), VAT numbers (*PVM mokėtojo kodas*) and IBANs, and routes each message to a "valid" or an "invalid" output.

Useful in form, CRM and invoicing flows: stop a mistyped company code or IBAN before it reaches an accounting system.

## Install

From the Node-RED editor: *Manage palette* → *Install* → `node-red-contrib-ltcodes`.

Or in your Node-RED user directory (usually `~/.node-red`):

```
npm install node-red-contrib-ltcodes
```

## Use

The **LT code check** node is in the *function* category.

- **Code in** – the message property that holds the code, `msg.payload` by default.
- **Check as** – any Lithuanian code, or only a personal code, a company code, a VAT number or an IBAN.

The node adds `msg.ltcodes`:

```json
{
  "code": "33309240064",
  "valid": true,
  "kinds": ["personal"],
  "birthDate": { "year": 1933, "month": 9, "day": 24 }
}
```

`kinds` lists everything the code is valid as (`personal`, `company`, `vat`, `iban`); a company code is often also a valid VAT number. An example flow is under *Import* → *Examples* → *node-red-contrib-ltcodes*.

## What is checked

- **Personal code**: 11 digits, the first digit gives the century and sex, the next six the birth date, and the last one is a check digit. Codes that start with 9 carry no date, so only the check digit is tested.
- **Company code**: 9 digits with a check digit.
- **VAT number**: 9 or 12 digits, with or without the `LT` prefix.
- **IBAN**: 20 characters that start with `LT`, checked with the MOD-97 rule.

The check digit only proves that a code is well formed, not that it was issued to anyone. The checks come from the [`@ellolt/ltcodes`](https://www.npmjs.com/package/@ellolt/ltcodes) package and pass the shared test cases of the [ltcodes repository](https://github.com/ello-lithuania/ltcodes).

Made by [KokybiskaSvetaine.lt](https://kokybiskasvetaine.lt/). Licence: MIT.
