/*
 * ltcodes - validate Lithuanian personal codes, company codes, VAT numbers
 * and IBANs. Plain C99, no allocations, no dependencies.
 *
 * A valid check digit only proves that a code is well formed, not that it
 * was issued to anyone.
 *
 * Made by KokybiskaSvetaine.lt (https://kokybiskasvetaine.lt/). MIT licence.
 */
#ifndef LTCODES_H
#define LTCODES_H

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Tests a personal code (asmens kodas): 11 digits, a valid birth date unless
 * the code starts with 9, and the check digit. */
bool ltcodes_is_personal_code(const char *code);

/* Reads the birth date in a personal code. Returns false when the code has no
 * valid date (codes that start with 9 carry none). Any output pointer may be
 * NULL. */
bool ltcodes_birth_date(const char *code, int *year, int *month, int *day);

/* Tests a company code (juridinio asmens kodas): 9 digits with a check digit. */
bool ltcodes_is_company_code(const char *code);

/* Tests a VAT number (PVM moketojo kodas): 9 or 12 digits, with or without
 * the LT prefix. Spaces and dashes are ignored. */
bool ltcodes_is_vat_number(const char *code);

/* Tests a Lithuanian IBAN: 20 characters, the LT prefix and the MOD-97 rule.
 * Spaces and dashes are ignored. */
bool ltcodes_is_iban(const char *code);

#ifdef __cplusplus
}
#endif

#endif /* LTCODES_H */
