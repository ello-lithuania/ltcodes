let is_digit c = c >= '0' && c <= '9'
let all_digits s = s <> "" && String.for_all is_digit s
let digit s i = Char.code s.[i] - 48

(* The shared check digit rule: weights 1 to 9, then 3 to 9, 1, 2 if the first
   pass gives 10. Reads the first [n] digits of [s]. *)
let check_digit s n =
  let pass shift =
    let sum = ref 0 in
    for i = 0 to n - 1 do
      sum := !sum + ((1 + ((i + shift) mod 9)) * digit s i)
    done;
    !sum mod 11
  in
  let first = pass 0 in
  if first <> 10 then first else pass 2 mod 10

let days_in_month y m =
  match m with
  | 1 | 3 | 5 | 7 | 8 | 10 | 12 -> 31
  | 4 | 6 | 9 | 11 -> 30
  | 2 -> if (y mod 4 = 0 && y mod 100 <> 0) || y mod 400 = 0 then 29 else 28
  | _ -> 0

let birth_date s =
  if String.length s <> 11 || not (all_digits s) then None
  else
    let century =
      match digit s 0 with
      | 1 | 2 -> Some 1800
      | 3 | 4 -> Some 1900
      | 5 | 6 -> Some 2000
      | _ -> None
    in
    match century with
    | None -> None
    | Some c ->
        let y = c + (digit s 1 * 10) + digit s 2 in
        let m = (digit s 3 * 10) + digit s 4 in
        let d = (digit s 5 * 10) + digit s 6 in
        if d >= 1 && d <= days_in_month y m then Some (y, m, d) else None

let is_personal_code s =
  String.length s = 11 && all_digits s
  && (digit s 0 = 9 || birth_date s <> None)
  && check_digit s 10 = digit s 10

let is_company_code s =
  String.length s = 9 && all_digits s && check_digit s 8 = digit s 8

let compact s =
  let b = Buffer.create (String.length s) in
  String.iter
    (fun c ->
      if not (c = ' ' || c = '\t' || c = '\n' || c = '-') then
        Buffer.add_char b (Char.uppercase_ascii c))
    s;
  Buffer.contents b

let is_vat_number s =
  let c = compact s in
  let c =
    if String.length c >= 2 && String.sub c 0 2 = "LT" then
      String.sub c 2 (String.length c - 2)
    else c
  in
  let n = String.length c in
  (n = 9 || n = 12) && all_digits c
  && digit c (if n = 9 then 7 else 10) = 1
  && check_digit c (n - 1) = digit c (n - 1)

let is_iban s =
  let c = compact s in
  String.length c = 20
  && String.sub c 0 2 = "LT"
  && all_digits (String.sub c 2 18)
  &&
  let moved = String.sub c 4 16 ^ "2129" ^ String.sub c 2 2 in
  let rem = ref 0 in
  String.iter (fun ch -> rem := ((!rem * 10) + Char.code ch - 48) mod 97) moved;
  !rem = 1
