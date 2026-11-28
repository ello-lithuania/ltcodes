# ltcodes cookbook

Installs [`ltcodes`](https://github.com/ello-lithuania/ltcodes), a small command that checks Lithuanian personal codes (*asmens kodas*), company codes (*juridinio asmens kodas*), VAT numbers (*PVM mokėtojo kodas*) and IBANs. Handy on servers that import customer or supplier data and need a quick check in scripts.

```
$ ltcodes 33309240064 123033512 "LT12 1000 0111 0100 1000" 33309240164
33309240064: valid personal code, born 1933-09-24
123033512: valid company code, VAT number
LT12 1000 0111 0100 1000: valid IBAN
33309240164: invalid
```

The exit status is 0 when every code is valid, 1 when any is invalid.

## Platforms

The cookbook downloads the prebuilt binary from the GitHub release and checks its SHA-256:

- Linux on x86_64 (Debian, Ubuntu, RHEL and compatible, Amazon Linux, Fedora, SUSE)
- macOS on Apple Silicon
- Windows on x86_64 (the folder is added to `PATH`)

## Usage

Add `recipe[ltcodes]` to the run list, or from another recipe:

```ruby
include_recipe 'ltcodes'
```

## Attributes

| Attribute | Default | Meaning |
|---|---|---|
| `node['ltcodes']['version']` | `0.2.1` | release to install |
| `node['ltcodes']['checksums']` | checksums of 0.2.1 | SHA-256 of each release archive |
| `node['ltcodes']['install_dir']` | `/opt/ltcodes`, `C:\ltcodes` | where the binary goes; on Linux and macOS it is linked from `/usr/local/bin` |

When you pin another version, set its checksums too.

## What is checked

- **Personal code**: 11 digits, the first digit gives the century and sex, the next six the birth date, and the last one is a check digit.
- **Company code**: 9 digits with a check digit.
- **VAT number**: 9 or 12 digits, with or without the `LT` prefix.
- **IBAN**: 20 characters that start with `LT`, checked with the MOD-97 rule.

The check digit only proves that a code is well formed, not that it was issued to anyone.

Made by [KokybiskaSvetaine.lt](https://kokybiskasvetaine.lt/). Licence: MIT.
