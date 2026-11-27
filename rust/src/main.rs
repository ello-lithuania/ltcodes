//! `ltcodes CODE...` – checks Lithuanian personal codes, company codes, VAT
//! numbers and IBANs from the command line.

use std::process::ExitCode;

const USAGE: &str = "usage: ltcodes CODE...

Checks Lithuanian personal codes (asmens kodas), company codes (juridinio
asmens kodas), VAT numbers (PVM moketojo kodas) and IBANs. Each code is
printed with what it is valid as, or \"invalid\".

Exit status: 0 when every code is valid, 1 when any is invalid,
2 on a usage error.";

/// Lists what a code is valid as; empty when it is valid as nothing.
fn describe(code: &str) -> Vec<String> {
    let mut kinds = Vec::new();
    if ltcodes::is_personal_code(code) {
        kinds.push(match ltcodes::birth_date(code) {
            Some((y, m, d)) => format!("personal code, born {y:04}-{m:02}-{d:02}"),
            None => "personal code".to_string(),
        });
    }
    if ltcodes::is_company_code(code) {
        kinds.push("company code".to_string());
    }
    if ltcodes::is_vat_number(code) {
        kinds.push("VAT number".to_string());
    }
    if ltcodes::is_iban(code) {
        kinds.push("IBAN".to_string());
    }
    kinds
}

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    if args.iter().any(|a| a == "-h" || a == "--help") {
        println!("{USAGE}");
        return ExitCode::SUCCESS;
    }
    if args.iter().any(|a| a == "-V" || a == "--version") {
        println!("ltcodes {}", env!("CARGO_PKG_VERSION"));
        return ExitCode::SUCCESS;
    }
    if args.is_empty() {
        eprintln!("{USAGE}");
        return ExitCode::from(2);
    }
    let mut all_valid = true;
    for code in &args {
        let kinds = describe(code);
        if kinds.is_empty() {
            all_valid = false;
            println!("{code}: invalid");
        } else {
            println!("{code}: valid {}", kinds.join(", "));
        }
    }
    if all_valid {
        ExitCode::SUCCESS
    } else {
        ExitCode::FAILURE
    }
}
