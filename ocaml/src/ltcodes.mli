(** Validate Lithuanian personal codes, company codes, VAT numbers and IBANs.

    A valid check digit only proves that a code is well formed, not that it was
    issued to anyone. *)

val is_personal_code : string -> bool
(** Tests a personal code (asmens kodas). *)

val birth_date : string -> (int * int * int) option
(** Returns the birth date in a personal code as [(year, month, day)]. *)

val is_company_code : string -> bool
(** Tests a company code (juridinio asmens kodas). *)

val is_vat_number : string -> bool
(** Tests a VAT number (PVM mokėtojo kodas), with or without the [LT] prefix. *)

val is_iban : string -> bool
(** Tests a Lithuanian IBAN: 20 characters, the [LT] prefix and the MOD-97 rule. *)
