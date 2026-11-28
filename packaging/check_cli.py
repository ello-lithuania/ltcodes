"""Checks an installed ltcodes command against the shared test vectors.

    python check_cli.py [test_vectors.json] [command]

Used by the conda recipe and the Chef cookbook test. Exit status 1 on any
failure.
"""
import json
import subprocess
import sys

LABEL = {"personal": "personal code", "company": "company code", "vat": "VAT number", "iban": "IBAN"}

path = sys.argv[1] if len(sys.argv) > 1 else "test_vectors.json"
command = sys.argv[2] if len(sys.argv) > 2 else "ltcodes"
with open(path, encoding="utf-8") as f:
    vectors = json.load(f)

failed = total = 0
for kind, label in LABEL.items():
    for expect in ("valid", "invalid"):
        for code in vectors[kind][expect]:
            out = subprocess.run([command, code], capture_output=True, text=True).stdout
            total += 1
            if (label in out) != (expect == "valid"):
                failed += 1
                print(f"FAIL {kind} {expect} {code!r}: {out.strip()}")

out = subprocess.run([command, "33309240064"], capture_output=True, text=True).stdout
total += 1
if "born 1933-09-24" not in out:
    failed += 1
    print(f"FAIL birth date: {out.strip()}")

print(f"{total - failed} of {total} passed")
sys.exit(1 if failed else 0)
