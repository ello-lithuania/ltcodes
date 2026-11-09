/// Validate Lithuanian personal codes, company codes, VAT numbers and IBANs.
module ltcodes;

import std.algorithm : all, filter, startsWith;
import std.array : array;
import std.ascii : isDigit, isWhite, toUpper;
import std.datetime.date : Date, DateTimeException;
import std.typecons : Nullable;
import std.utf : byChar;

private int[] digitsOf(string s) pure @safe
{
    int[] d;
    foreach (c; s.byChar)
        d ~= c - '0';
    return d;
}

private bool allDigits(string s) pure @safe
{
    return s.length > 0 && s.byChar.all!isDigit;
}

// The shared check digit rule: weights 1 to 9, then 3 to 9, 1, 2 if the first
// pass gives 10.
private int checkDigit(const int[] d) pure @safe
{
    int pass(int shift)
    {
        int sum = 0;
        foreach (i, n; d)
            sum += (1 + (cast(int) i + shift) % 9) * n;
        return sum % 11;
    }

    immutable first = pass(0);
    return first != 10 ? first : pass(2) % 10;
}

/// Returns the birth date in a personal code, if it holds a valid one.
Nullable!Date birthDate(string code) @safe
{
    Nullable!Date none;
    if (code.length != 11 || !allDigits(code))
        return none;
    auto d = digitsOf(code);
    int century;
    switch (d[0])
    {
    case 1: case 2: century = 1800; break;
    case 3: case 4: century = 1900; break;
    case 5: case 6: century = 2000; break;
    default: return none;
    }
    try
        return Nullable!Date(Date(century + d[1] * 10 + d[2], d[3] * 10 + d[4], d[5] * 10 + d[6]));
    catch (DateTimeException)
        return none;
}

/// Tests a personal code (asmens kodas).
bool isPersonalCode(string code) @safe
{
    if (code.length != 11 || !allDigits(code))
        return false;
    auto d = digitsOf(code);
    if (d[0] != 9 && birthDate(code).isNull)
        return false;
    return checkDigit(d[0 .. 10]) == d[10];
}

/// Tests a company code (juridinio asmens kodas).
bool isCompanyCode(string code) @safe
{
    if (code.length != 9 || !allDigits(code))
        return false;
    auto d = digitsOf(code);
    return checkDigit(d[0 .. 8]) == d[8];
}

private string compact(string s) @safe
{
    string o;
    foreach (c; s.byChar)
        if (!isWhite(c) && c != '-')
            o ~= toUpper(c);
    return o;
}

/// Tests a VAT number (PVM mokėtojo kodas), with or without the LT prefix.
bool isVatNumber(string code) @safe
{
    auto c = compact(code);
    if (c.startsWith("LT"))
        c = c[2 .. $];
    if ((c.length != 9 && c.length != 12) || !allDigits(c))
        return false;
    auto d = digitsOf(c);
    immutable marker = c.length == 9 ? 7 : 10;
    return d[marker] == 1 && checkDigit(d[0 .. $ - 1]) == d[$ - 1];
}

/// Tests a Lithuanian IBAN: 20 characters, the LT prefix and the MOD-97 rule.
bool isIban(string code) @safe
{
    auto c = compact(code);
    if (c.length != 20 || !c.startsWith("LT") || !allDigits(c[2 .. $]))
        return false;
    int rem = 0;
    foreach (n; digitsOf(c[4 .. $] ~ "2129" ~ c[2 .. 4]))
        rem = (rem * 10 + n) % 97;
    return rem == 1;
}

@safe unittest
{
    assert(birthDate("33309240064").get == Date(1933, 9, 24));
    assert(birthDate("33313240064").isNull);
    foreach (c; ["33309240064", "90000000009"]) assert(isPersonalCode(c), c);
    foreach (c; ["33309240164", "33313240064", "3330924006", "3330924006X", "", "00000000000"]) assert(!isPersonalCode(c), c);
    foreach (c; ["110003978", "123033512", "121215434", "112021238"]) assert(isCompanyCode(c), c);
    foreach (c; ["110003979", "12303351", "1230335120", "12303351X", ""]) assert(!isCompanyCode(c), c);
    foreach (c; ["LT119511515", "119511515", "LT100001919017", "lt 100001919017"]) assert(isVatNumber(c), c);
    foreach (c; ["LT100001919018", "LT119511516", "LT11951151", "DE119511515", ""]) assert(!isVatNumber(c), c);
    foreach (c; ["LT121000011101001000", "LT12 1000 0111 0100 1000", "lt121000011101001000"]) assert(isIban(c), c);
    foreach (c; ["LT121000011101001001", "LT12100001110100100", "DE121000011101001000", ""]) assert(!isIban(c), c);
}
