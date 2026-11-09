let check name f good bad =
  List.iter (fun c -> if not (f c) then failwith (name ^ " should accept " ^ c)) good;
  List.iter (fun c -> if f c then failwith (name ^ " should reject " ^ c)) bad

let () =
  check "personal" Ltcodes.is_personal_code ["33309240064"; "90000000009"] ["33309240164"; "33313240064"; "3330924006"; "3330924006X"; ""; "00000000000"];
  check "company" Ltcodes.is_company_code ["110003978"; "123033512"; "121215434"; "112021238"] ["110003979"; "12303351"; "1230335120"; "12303351X"; ""];
  check "vat" Ltcodes.is_vat_number ["LT119511515"; "119511515"; "LT100001919017"; "lt 100001919017"] ["LT100001919018"; "LT119511516"; "LT11951151"; "DE119511515"; ""];
  check "iban" Ltcodes.is_iban ["LT121000011101001000"; "LT12 1000 0111 0100 1000"; "lt121000011101001000"] ["LT121000011101001001"; "LT12100001110100100"; "DE121000011101001000"; ""];
  assert (Ltcodes.birth_date "33309240064" = Some (1933, 9, 24));
  assert (Ltcodes.birth_date "33313240064" = None)
