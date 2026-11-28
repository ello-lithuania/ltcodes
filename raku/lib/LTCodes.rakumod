unit module LTCodes;

# Validate Lithuanian personal codes, company codes, VAT numbers and IBANs.
# A valid check digit only proves that a code is well formed, not that it
# was issued to anyone.

sub digits(Str $s) {
    $s ~~ /^ <[0..9]>+ $/ ?? $s.comb».Int !! ()
}

# The shared check digit rule: weights 1 to 9, then 3 to 9, 1, 2 if the
# first pass gives 10.
sub check-digit(@d --> Int) {
    my sub weighted(Int $shift) { (^@d).map({ (1 + ($_ + $shift) % 9) * @d[$_] }).sum % 11 }
    my $first = weighted(0);
    $first != 10 ?? $first !! weighted(2) % 10
}

sub days-in-month(Int $y, Int $m --> Int) {
    given $m {
        when 1 | 3 | 5 | 7 | 8 | 10 | 12 { 31 }
        when 4 | 6 | 9 | 11 { 30 }
        when 2 { ($y %% 4 && $y !%% 100) || $y %% 400 ?? 29 !! 28 }
        default { 0 }
    }
}

my %century = 1 => 1800, 2 => 1800, 3 => 1900, 4 => 1900, 5 => 2000, 6 => 2000;

#| The birth date in a personal code, or Nil when it has no valid date
#| (codes that start with 9 carry none).
sub birth-date(Str:D $code --> Date) is export {
    my @d = digits($code);
    return Nil unless @d == 11 && (%century{@d[0]}:exists);
    my $y = %century{@d[0]} + @d[1] * 10 + @d[2];
    my $m = @d[3] * 10 + @d[4];
    my $day = @d[5] * 10 + @d[6];
    return Nil unless 1 <= $day <= days-in-month($y, $m);
    Date.new($y, $m, $day)
}

#| Tests a personal code (asmens kodas).
sub is-personal-code(Str:D $code --> Bool) is export {
    my @d = digits($code);
    return False unless @d == 11;
    return False unless @d[0] == 9 || birth-date($code).defined;
    check-digit(@d[^10]) == @d[10]
}

#| Tests a company code (juridinio asmens kodas).
sub is-company-code(Str:D $code --> Bool) is export {
    my @d = digits($code);
    @d == 9 && check-digit(@d[^8]) == @d[8]
}

sub compact(Str $s) { $s.subst(/ \s | '-' /, '', :g).uc }

#| Tests a VAT number (PVM mokėtojo kodas), with or without the LT prefix.
sub is-vat-number(Str:D $code --> Bool) is export {
    my $c = compact($code);
    $c .= substr(2) if $c.starts-with('LT');
    my @d = digits($c);
    return False unless @d == 9 | 12;
    my $marker = @d == 9 ?? 7 !! 10;
    @d[$marker] == 1 && check-digit(@d[0 ..^ @d.end]) == @d[*-1]
}

#| Tests a Lithuanian IBAN: 20 characters, the LT prefix and the MOD-97 rule.
sub is-iban(Str:D $code --> Bool) is export {
    my $c = compact($code);
    return False unless $c.chars == 20 && $c.starts-with('LT');
    my $rem = 0;
    for ($c.substr(4) ~ $c.substr(0, 4)).comb -> $ch {
        if $ch ~~ /^ <[0..9]> $/ { $rem = ($rem * 10 + $ch.Int) % 97 }
        elsif $ch ~~ /^ <[A..Z]> $/ { $rem = ($rem * 100 + $ch.ord - 55) % 97 }
        else { return False }
    }
    $rem == 1
}

#| Lists what a code is valid as: personal, company, vat and iban.
sub code-kinds(Str:D $code --> List) is export {
    (
        ('personal' if is-personal-code($code)),
        ('company' if is-company-code($code)),
        ('vat' if is-vat-number($code)),
        ('iban' if is-iban($code)),
    ).List
}
