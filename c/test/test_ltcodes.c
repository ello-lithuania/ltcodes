/* Reads test cases from stdin, one per line: KIND<TAB>EXPECT<TAB>CODE, where
 * KIND is personal, company, vat or iban and EXPECT is valid or invalid.
 * cases.py writes them from test_vectors.json. Exit status 1 on any failure. */
#include <stdio.h>
#include <string.h>

#include "ltcodes.h"

int main(void)
{
    char line[256];
    int failed = 0, total = 0;
    while (fgets(line, sizeof line, stdin)) {
        line[strcspn(line, "\r\n")] = '\0';
        char *kind = strtok(line, "\t");
        char *expect = strtok(NULL, "\t");
        if (kind == NULL || expect == NULL) {
            continue;
        }
        char *code = expect + strlen(expect) + 1;
        bool want = strcmp(expect, "valid") == 0;
        bool got;
        if (strcmp(kind, "personal") == 0) got = ltcodes_is_personal_code(code);
        else if (strcmp(kind, "company") == 0) got = ltcodes_is_company_code(code);
        else if (strcmp(kind, "vat") == 0) got = ltcodes_is_vat_number(code);
        else if (strcmp(kind, "iban") == 0) got = ltcodes_is_iban(code);
        else {
            printf("unknown kind: %s\n", kind);
            return 1;
        }
        total++;
        if (got != want) {
            failed++;
            printf("FAIL %s %s '%s'\n", kind, expect, code);
        }
    }
    int y = 0, m = 0, d = 0;
    total++;
    if (!ltcodes_birth_date("33309240064", &y, &m, &d) || y != 1933 || m != 9 || d != 24) {
        failed++;
        printf("FAIL birth date %d-%d-%d\n", y, m, d);
    }
    total++;
    if (ltcodes_birth_date("90000000009", NULL, NULL, NULL)) {
        failed++;
        printf("FAIL no birth date for 9...\n");
    }
    printf("%d of %d passed\n", total - failed, total);
    return failed ? 1 : 0;
}
