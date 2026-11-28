:- module(ltcodes,
          [ lt_personal_code/1,         % +Code
            lt_birth_date/2,            % +Code, -Date
            lt_company_code/1,          % +Code
            lt_vat_number/1,            % +Code
            lt_iban/1                   % +Code
          ]).
:- use_module(library(lists)).
:- use_module(library(apply)).

/** <module> Validate Lithuanian personal codes, company codes, VAT numbers and IBANs

Codes are given as atoms or strings.

```
?- lt_personal_code("33309240064").
true.

?- lt_birth_date('33309240064', D).
D = date(1933, 9, 24).

?- lt_iban("LT12 1000 0111 0100 1000").
true.
```

A valid check digit only proves that a code is well formed, not that it
was issued to anyone.

@author KokybiskaSvetaine.lt, https://kokybiskasvetaine.lt/
@license MIT
*/

%!  lt_personal_code(+Code) is semidet.
%
%   True when Code is a valid personal code (asmens kodas): 11 digits,
%   a valid birth date unless the code starts with 9, and the check
%   digit.

lt_personal_code(Code) :-
    code_digits(Code, Ds),
    length(Ds, 11),
    (   Ds = [9|_]
    ->  true
    ;   lt_birth_date(Code, _)
    ),
    valid_check_digit(Ds).

%!  lt_birth_date(+Code, -Date) is semidet.
%
%   Date is the birth date in a personal code as date(Year, Month, Day).
%   Fails when the code has no valid date; codes that start with 9 carry
%   none.

lt_birth_date(Code, date(Y, M, D)) :-
    code_digits(Code, Ds),
    length(Ds, 11),
    Ds = [C, Y1, Y2, M1, M2, D1, D2|_],
    century(C, Century),
    Y is Century + Y1*10 + Y2,
    M is M1*10 + M2,
    D is D1*10 + D2,
    days_in_month(Y, M, Max),
    D >= 1,
    D =< Max.

%!  lt_company_code(+Code) is semidet.
%
%   True when Code is a valid company code (juridinio asmens kodas): 9
%   digits with a check digit.

lt_company_code(Code) :-
    code_digits(Code, Ds),
    length(Ds, 9),
    valid_check_digit(Ds).

%!  lt_vat_number(+Code) is semidet.
%
%   True when Code is a valid VAT number (PVM mokėtojo kodas): 9 or 12
%   digits, with or without the `LT` prefix.

lt_vat_number(Code) :-
    compact(Code, S0),
    (   string_concat("LT", S, S0)
    ->  true
    ;   S = S0
    ),
    code_digits(S, Ds),
    length(Ds, Len),
    (   Len =:= 9
    ->  Marker = 7
    ;   Len =:= 12
    ->  Marker = 10
    ),
    nth0(Marker, Ds, 1),
    valid_check_digit(Ds).

%!  lt_iban(+Code) is semidet.
%
%   True when Code is a Lithuanian IBAN: 20 characters, the `LT` prefix
%   and the MOD-97 rule. Spaces and dashes are ignored.

lt_iban(Code) :-
    compact(Code, S),
    string_length(S, 20),
    sub_string(S, 0, 2, _, "LT"),
    sub_string(S, 0, 4, _, Head),
    sub_string(S, 4, _, 0, Tail),
    string_concat(Tail, Head, Moved),
    string_codes(Moved, Cs),
    foldl(mod97, Cs, 0, Rem),
    Rem =:= 1.

mod97(C, R0, R) :-
    (   C >= 0'0, C =< 0'9
    ->  R is (R0*10 + C - 0'0) mod 97
    ;   C >= 0'A, C =< 0'Z
    ->  R is (R0*100 + C - 0'A + 10) mod 97
    ).

% The shared check digit rule: weights 1 to 9, then 3 to 9, 1, 2 if the
% first pass gives 10.

valid_check_digit(Ds) :-
    append(Body, [Check], Ds),
    check_digit(Body, Check).

check_digit(Body, Check) :-
    weighted_sum(Body, 0, 0, S1),
    R1 is S1 mod 11,
    (   R1 =\= 10
    ->  Check =:= R1
    ;   weighted_sum(Body, 2, 0, S2),
        Check =:= (S2 mod 11) mod 10
    ).

weighted_sum([], _, Sum, Sum).
weighted_sum([D|Ds], I, S0, Sum) :-
    S is S0 + (1 + I mod 9) * D,
    I1 is I + 1,
    weighted_sum(Ds, I1, S, Sum).

code_digits(Code, Ds) :-
    text(Code, S),
    string_codes(S, Cs),
    Cs \== [],
    maplist(digit, Cs, Ds).

digit(C, D) :-
    C >= 0'0,
    C =< 0'9,
    D is C - 0'0.

compact(Code, S) :-
    text(Code, S0),
    string_chars(S0, Cs0),
    exclude(ignored_char, Cs0, Cs),
    string_chars(S1, Cs),
    string_upper(S1, S).

ignored_char(C) :-
    (   C == '-'
    ->  true
    ;   char_type(C, space)
    ).

text(Code, S) :-
    (   atom(Code)
    ;   string(Code)
    ),
    !,
    atom_string(Code, S).

century(1, 1800).
century(2, 1800).
century(3, 1900).
century(4, 1900).
century(5, 2000).
century(6, 2000).

days_in_month(_, M, 31) :- memberchk(M, [1, 3, 5, 7, 8, 10, 12]), !.
days_in_month(_, M, 30) :- memberchk(M, [4, 6, 9, 11]), !.
days_in_month(Y, 2, 29) :- leap_year(Y), !.
days_in_month(_, 2, 28).

leap_year(Y) :-
    (   Y mod 400 =:= 0
    ->  true
    ;   Y mod 4 =:= 0,
        Y mod 100 =\= 0
    ).
