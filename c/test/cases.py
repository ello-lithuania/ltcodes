"""Prints the shared test vectors as KIND<TAB>EXPECT<TAB>CODE lines for test_ltcodes.c."""
import json
import pathlib
import sys

root = pathlib.Path(__file__).resolve().parents[2]
vectors = json.loads((root / "test_vectors.json").read_text(encoding="utf-8"))
out = []
for kind, cases in vectors.items():
    for expect in ("valid", "invalid"):
        for code in cases[expect]:
            out.append(f"{kind}\t{expect}\t{code}")
sys.stdout.write("\n".join(out) + "\n")
