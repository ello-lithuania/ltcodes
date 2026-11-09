//! Validate Lithuanian personal codes, company codes, VAT numbers and IBANs.
//!
//! ```
//! assert!(ltcodes::is_personal_code("33309240064"));
//! assert!(ltcodes::is_company_code("123033512"));
//! assert!(ltcodes::is_vat_number("LT119511515"));
//! assert!(ltcodes::is_iban("LT121000011101001000"));
//! ```
//!
//! A valid check digit only proves that a code is well formed, not that it was
//! issued to anyone.
#![forbid(unsafe_code)]

fn digits(s: &str) -> Option<Vec<u32>> {
    if s.is_empty() {
        return None;
    }
    s.chars().map(|c| c.to_digit(10)).collect()
}

/// The shared check digit rule: weights 1 to 9, then 3 to 9, 1, 2 if the first
/// pass gives 10.
fn check_digit(d: &[u32]) -> u32 {
    let pass = |shift: usize| -> u32 {
        d.iter()
            .enumerate()
            .map(|(i, n)| (1 + ((i + shift) % 9) as u32) * n)
            .sum::<u32>()
            % 11
    };
    let first = pass(0);
    if first != 10 {
        return first;
    }
    pass(2) % 10
}

fn days_in_month(year: u32, month: u32) -> u32 {
    match month {
        1 | 3 | 5 | 7 | 8 | 10 | 12 => 31,
        4 | 6 | 9 | 11 => 30,
        2 if (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 => 29,
        2 => 28,
        _ => 0,
    }
}

/// Returns the birth date in a personal code as (year, month, day).
///
/// Gives `None` when the code has no valid date, or when it starts with 9 and
/// so carries no date at all.
pub fn birth_date(code: &str) -> Option<(u32, u32, u32)> {
    let d = digits(code)?;
    if d.len() != 11 {
        return None;
    }
    let century = match d[0] {
        1 | 2 => 1800,
        3 | 4 => 1900,
        5 | 6 => 2000,
        _ => return None,
    };
    let (y, m, day) = (century + d[1] * 10 + d[2], d[3] * 10 + d[4], d[5] * 10 + d[6]);
    if day < 1 || day > days_in_month(y, m) {
        return None;
    }
    Some((y, m, day))
}

/// Tests a personal code (asmens kodas).
pub fn is_personal_code(code: &str) -> bool {
    let Some(d) = digits(code) else { return false };
    if d.len() != 11 || (d[0] != 9 && birth_date(code).is_none()) {
        return false;
    }
    check_digit(&d[..10]) == d[10]
}

/// Tests a company code (juridinio asmens kodas).
pub fn is_company_code(code: &str) -> bool {
    let Some(d) = digits(code) else { return false };
    d.len() == 9 && check_digit(&d[..8]) == d[8]
}

fn compact(s: &str) -> String {
    s.chars()
        .filter(|c| !c.is_whitespace() && *c != '-')
        .collect::<String>()
        .to_uppercase()
}

/// Tests a VAT number (PVM mokėtojo kodas), with or without the `LT` prefix.
pub fn is_vat_number(code: &str) -> bool {
    let c = compact(code);
    let c = c.strip_prefix("LT").unwrap_or(&c);
    let Some(d) = digits(c) else { return false };
    let marker = match d.len() {
        9 => 7,
        12 => 10,
        _ => return false,
    };
    d[marker] == 1 && check_digit(&d[..d.len() - 1]) == d[d.len() - 1]
}

/// Tests a Lithuanian IBAN: 20 characters, the `LT` prefix and the MOD-97 rule.
pub fn is_iban(code: &str) -> bool {
    let c = compact(code);
    if c.len() != 20 || !c.starts_with("LT") {
        return false;
    }
    let (head, tail) = c.split_at(4);
    let mut rem: u32 = 0;
    for ch in tail.chars().chain(head.chars()) {
        let Some(v) = ch.to_digit(36) else { return false };
        rem = if v > 9 { (rem * 100 + v) % 97 } else { (rem * 10 + v) % 97 };
    }
    rem == 1
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn date() {
        assert_eq!(birth_date("33309240064"), Some((1933, 9, 24)));
        assert_eq!(birth_date("33313240064"), None);
    }

    #[test]
    fn personal() {
        for c in ["33309240064", "90000000009"] {
            assert!(is_personal_code(c), "{c}");
        }
        for c in ["33309240164", "33313240064", "3330924006", "3330924006X", "", "00000000000"] {
            assert!(!is_personal_code(c), "{c}");
        }
    }

    #[test]
    fn company() {
        for c in ["110003978", "123033512", "121215434", "112021238"] {
            assert!(is_company_code(c), "{c}");
        }
        for c in ["110003979", "12303351", "1230335120", "12303351X", ""] {
            assert!(!is_company_code(c), "{c}");
        }
    }

    #[test]
    fn vat() {
        for c in ["LT119511515", "119511515", "LT100001919017", "lt 100001919017"] {
            assert!(is_vat_number(c), "{c}");
        }
        for c in ["LT100001919018", "LT119511516", "LT11951151", "DE119511515", ""] {
            assert!(!is_vat_number(c), "{c}");
        }
    }

    #[test]
    fn iban() {
        for c in ["LT121000011101001000", "LT12 1000 0111 0100 1000", "lt121000011101001000"] {
            assert!(is_iban(c), "{c}");
        }
        for c in ["LT121000011101001001", "LT12100001110100100", "DE121000011101001000", ""] {
            assert!(!is_iban(c), "{c}");
        }
    }
}
