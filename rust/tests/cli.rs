use std::process::Command;

fn run(args: &[&str]) -> (i32, String) {
    let out = Command::new(env!("CARGO_BIN_EXE_ltcodes"))
        .args(args)
        .output()
        .expect("run ltcodes");
    (
        out.status.code().unwrap_or(-1),
        String::from_utf8_lossy(&out.stdout).into_owned(),
    )
}

#[test]
fn valid_codes() {
    let (code, out) = run(&["33309240064", "123033512", "LT119511515", "LT121000011101001000"]);
    assert_eq!(code, 0, "{out}");
    assert!(out.contains("33309240064: valid personal code, born 1933-09-24"), "{out}");
    assert!(out.contains("123033512: valid company code"), "{out}");
    assert!(out.contains("LT119511515: valid VAT number"), "{out}");
    assert!(out.contains("LT121000011101001000: valid IBAN"), "{out}");
}

#[test]
fn invalid_code() {
    let (code, out) = run(&["33309240064", "33309240164"]);
    assert_eq!(code, 1, "{out}");
    assert!(out.contains("33309240164: invalid"), "{out}");
}

#[test]
fn usage() {
    assert_eq!(run(&[]).0, 2);
    assert_eq!(run(&["--help"]).0, 0);
    let (code, out) = run(&["--version"]);
    assert_eq!(code, 0);
    assert!(out.starts_with("ltcodes "), "{out}");
}
