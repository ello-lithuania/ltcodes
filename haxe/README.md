# ltcodes for Haxe

Validate Lithuanian personal codes, company codes, VAT numbers and IBANs. No dependencies, works on every Haxe target.

```
haxelib install ltcodes
```

```haxe
import ltcodes.LtCodes;

LtCodes.isPersonalCode("33309240064");      // true
LtCodes.birthDate("33309240064");           // [1933, 9, 24]
LtCodes.isCompanyCode("123033512");         // true
LtCodes.isVatNumber("LT119511515");         // true
LtCodes.isIban("LT12 1000 0111 0100 1000"); // true
```

The rules and the shared test cases are described in the [main README](https://github.com/ello-lithuania/ltcodes). A valid check digit only proves that a code is well formed, not that it was issued to anyone.

Tests: `haxe -cp src -cp test -main Test --interp` (reads `../test_vectors.json`).

Made and maintained by [KokybiskaSvetaine.lt](https://kokybiskasvetaine.lt/), a web development studio in Lithuania. MIT licence.
