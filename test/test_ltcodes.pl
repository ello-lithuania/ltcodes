% Tests for the SWI-Prolog pack: swipl -g run_tests -t halt test/test_ltcodes.pl

:- use_module(library(plunit)).
:- use_module(library(http/json)).
:- use_module('../prolog/ltcodes').

:- dynamic test_dir/1.
:- prolog_load_context(directory, Dir),
   retractall(test_dir(_)),
   assertz(test_dir(Dir)).

vector(Kind, Expect, Code) :-
    test_dir(Dir),
    directory_file_path(Dir, '../test_vectors.json', File),
    setup_call_cleanup(open(File, read, In, [encoding(utf8)]),
                       json_read_dict(In, Vectors),
                       close(In)),
    get_dict(Kind, Vectors, ByKind),
    get_dict(Expect, ByKind, Codes),
    member(Code, Codes).

check(personal, lt_personal_code).
check(company, lt_company_code).
check(vat, lt_vat_number).
check(iban, lt_iban).

:- begin_tests(ltcodes).

test(valid, [forall((check(Kind, P), vector(Kind, valid, Code)))]) :-
    call(P, Code).

test(invalid, [forall((check(Kind, P), vector(Kind, invalid, Code))), fail]) :-
    call(P, Code).

test(birth_date) :-
    lt_birth_date('33309240064', date(1933, 9, 24)).

test(no_birth_date, fail) :-
    lt_birth_date("90000000009", _).

test(not_text, fail) :-
    lt_company_code(123033512).

:- end_tests(ltcodes).
