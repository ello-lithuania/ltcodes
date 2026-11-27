# ltcodes for Clojure

Validate Lithuanian personal codes, company codes, VAT numbers and IBANs. No dependencies besides Clojure.

```clojure
;; deps.edn
net.clojars.ellolt/ltcodes {:mvn/version "1.0.0"}
```

```clojure
(require '[ltcodes.core :as lt])

(lt/personal-code? "33309240064")      ;=> true
(lt/birth-date "33309240064")          ;=> [1933 9 24]
(lt/company-code? "123033512")         ;=> true
(lt/vat-number? "LT119511515")         ;=> true
(lt/iban? "LT12 1000 0111 0100 1000")  ;=> true
```

The rules and the shared test cases are described in the [main README](../README.md). A valid check digit only proves that a code is well formed, not that it was issued to anyone.

Tests: `clojure -X:test` (reads `../test_vectors.json`).

Made and maintained by [KokybiskaSvetaine.lt](https://kokybiskasvetaine.lt/), a web development studio in Lithuania. MIT licence.
