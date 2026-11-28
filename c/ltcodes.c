/* ltcodes - see include/ltcodes.h. MIT licence. */
#include "ltcodes.h"

#include <stddef.h>

#define MAX_DIGITS 12
#define COMPACT_MAX 32

/* Copies the digits of s into d. Returns the count, or -1 when s is empty,
 * holds anything but ASCII digits or is longer than max. */
static int read_digits(const char *s, int *d, int max)
{
    int n = 0;
    if (s == NULL || *s == '\0') {
        return -1;
    }
    for (; *s != '\0'; s++) {
        if (*s < '0' || *s > '9' || n == max) {
            return -1;
        }
        d[n++] = *s - '0';
    }
    return n;
}

/* The shared check digit rule: weights 1 to 9, then 3 to 9, 1, 2 if the
 * first pass gives 10. */
static int weighted(const int *d, int n, int shift)
{
    int sum = 0;
    for (int i = 0; i < n; i++) {
        sum += (1 + (i + shift) % 9) * d[i];
    }
    return sum % 11;
}

static int check_digit(const int *d, int n)
{
    int first = weighted(d, n, 0);
    return first != 10 ? first : weighted(d, n, 2) % 10;
}

static int days_in_month(int y, int m)
{
    switch (m) {
    case 1: case 3: case 5: case 7: case 8: case 10: case 12:
        return 31;
    case 4: case 6: case 9: case 11:
        return 30;
    case 2:
        return ((y % 4 == 0 && y % 100 != 0) || y % 400 == 0) ? 29 : 28;
    default:
        return 0;
    }
}

bool ltcodes_birth_date(const char *code, int *year, int *month, int *day)
{
    int d[MAX_DIGITS];
    int century;
    if (read_digits(code, d, MAX_DIGITS) != 11) {
        return false;
    }
    switch (d[0]) {
    case 1: case 2: century = 1800; break;
    case 3: case 4: century = 1900; break;
    case 5: case 6: century = 2000; break;
    default: return false;
    }
    int y = century + d[1] * 10 + d[2];
    int m = d[3] * 10 + d[4];
    int dd = d[5] * 10 + d[6];
    if (dd < 1 || dd > days_in_month(y, m)) {
        return false;
    }
    if (year) *year = y;
    if (month) *month = m;
    if (day) *day = dd;
    return true;
}

bool ltcodes_is_personal_code(const char *code)
{
    int d[MAX_DIGITS];
    if (read_digits(code, d, MAX_DIGITS) != 11) {
        return false;
    }
    if (d[0] != 9 && !ltcodes_birth_date(code, NULL, NULL, NULL)) {
        return false;
    }
    return check_digit(d, 10) == d[10];
}

bool ltcodes_is_company_code(const char *code)
{
    int d[MAX_DIGITS];
    return read_digits(code, d, MAX_DIGITS) == 9 && check_digit(d, 8) == d[8];
}

/* Drops spaces and dashes and upper-cases ASCII letters. Returns false when
 * the result would not fit. */
static bool compact(const char *s, char *out, size_t size)
{
    size_t n = 0;
    if (s == NULL) {
        return false;
    }
    for (; *s != '\0'; s++) {
        char c = *s;
        if (c == ' ' || c == '-' || c == '\t' || c == '\n' || c == '\r') {
            continue;
        }
        if (c >= 'a' && c <= 'z') {
            c = (char)(c - 'a' + 'A');
        }
        if (n + 1 >= size) {
            return false;
        }
        out[n++] = c;
    }
    out[n] = '\0';
    return true;
}

bool ltcodes_is_vat_number(const char *code)
{
    char c[COMPACT_MAX];
    int d[MAX_DIGITS];
    if (!compact(code, c, sizeof c)) {
        return false;
    }
    const char *p = (c[0] == 'L' && c[1] == 'T') ? c + 2 : c;
    int n = read_digits(p, d, MAX_DIGITS);
    if (n != 9 && n != 12) {
        return false;
    }
    int marker = n == 9 ? 7 : 10;
    return d[marker] == 1 && check_digit(d, n - 1) == d[n - 1];
}

bool ltcodes_is_iban(const char *code)
{
    char c[COMPACT_MAX];
    size_t len = 0;
    if (!compact(code, c, sizeof c)) {
        return false;
    }
    while (c[len] != '\0') {
        len++;
    }
    if (len != 20 || c[0] != 'L' || c[1] != 'T') {
        return false;
    }
    unsigned rem = 0;
    for (size_t i = 0; i < 20; i++) {
        char ch = c[(i + 4) % 20];
        if (ch >= '0' && ch <= '9') {
            rem = (rem * 10 + (unsigned)(ch - '0')) % 97;
        } else if (ch >= 'A' && ch <= 'Z') {
            rem = (rem * 100 + (unsigned)(ch - 'A' + 10)) % 97;
        } else {
            return false;
        }
    }
    return rem == 1;
}
