%global debug_package %{nil}

Name:           ltcodes
Version:        0.2.0
Release:        1%{?dist}
Summary:        Validate Lithuanian personal codes, company codes, VAT numbers and IBANs

License:        MIT
URL:            https://kokybiskasvetaine.lt/
Source0:        https://github.com/ello-lithuania/ltcodes/archive/refs/tags/rust-v%{version}.tar.gz#/%{name}-%{version}.tar.gz

BuildRequires:  cargo
BuildRequires:  rust

%description
A small command line tool that checks Lithuanian personal codes (asmens kodas),
company codes (juridinio asmens kodas), VAT numbers (PVM moketojo kodas) and
IBANs. Each code is printed with what it is valid as, or "invalid"; the exit
status is 0 when every code is valid. Made by KokybiskaSvetaine.lt.

%prep
%autosetup -n ltcodes-rust-v%{version}

%build
cd rust
cargo build --release --offline

%check
cd rust
cargo test --release --offline

%install
install -Dpm 0755 rust/target/release/ltcodes %{buildroot}%{_bindir}/ltcodes

%files
%license rust/LICENSE
%doc rust/README.md
%{_bindir}/ltcodes

%changelog
* Fri Nov 27 2026 Justas Arbatauskis <info@kokybiskasvetaine.lt> - 0.2.0-1
- First package: the ltcodes command
