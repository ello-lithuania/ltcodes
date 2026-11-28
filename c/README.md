# ltcodes for C and ESP-IDF

Validate Lithuanian personal codes, company codes, VAT numbers and IBANs in plain C99. Two files, no allocations, no dependencies, so it fits on a microcontroller as well as on a server.

## ESP-IDF

```
idf.py add-dependency "ello-lithuania/ltcodes"
```

```c
#include "ltcodes.h"

if (ltcodes_is_iban("LT12 1000 0111 0100 1000")) {
    /* ... */
}
```

## Any other C project

Copy `ltcodes.c` and `include/ltcodes.h`, or add this folder with CMake:

```cmake
add_subdirectory(ltcodes/c)
target_link_libraries(your_app ltcodes)
```

## Functions

```c
bool ltcodes_is_personal_code(const char *code);   /* asmens kodas */
bool ltcodes_birth_date(const char *code, int *year, int *month, int *day);
bool ltcodes_is_company_code(const char *code);    /* juridinio asmens kodas */
bool ltcodes_is_vat_number(const char *code);      /* PVM mokėtojo kodas */
bool ltcodes_is_iban(const char *code);
```

## What is checked

- **Personal code**: 11 digits, the first digit gives the century and sex, the next six the birth date, and the last one is a check digit. Codes that start with 9 carry no date, so only the check digit is tested.
- **Company code**: 9 digits with a check digit.
- **VAT number**: 9 or 12 digits, with or without the `LT` prefix.
- **IBAN**: 20 characters that start with `LT`, checked with the MOD-97 rule.

The check digit only proves that a code is well formed, not that it was issued to anyone.

## Tests

```
cmake -S . -B build && cmake --build build
python3 test/cases.py | ./build/test_ltcodes
```

The cases are the shared test vectors of the [ltcodes repository](https://github.com/ello-lithuania/ltcodes), which also has the same rules in Rust, JavaScript, R, D, OCaml and other languages.

Made by [KokybiskaSvetaine.lt](https://kokybiskasvetaine.lt/). Licence: MIT.
