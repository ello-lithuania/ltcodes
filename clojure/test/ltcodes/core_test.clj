(ns ltcodes.core-test
  (:require [clojure.test :refer [deftest is testing]]
            [clojure.data.json :as json]
            [ltcodes.core :as lt]))

(def vectors (json/read-str (slurp "../test_vectors.json")))

(defn- check [kind f]
  (testing kind
    (doseq [c (get-in vectors [kind "valid"])] (is (true? (f c)) (str "valid: " (pr-str c))))
    (doseq [c (get-in vectors [kind "invalid"])] (is (false? (f c)) (str "invalid: " (pr-str c))))))

(deftest shared-vectors
  (check "personal" lt/personal-code?)
  (check "company" lt/company-code?)
  (check "vat" lt/vat-number?)
  (check "iban" lt/iban?))

(deftest birth-dates
  (is (= [1933 9 24] (lt/birth-date "33309240064")))
  (is (nil? (lt/birth-date "90000000009")))
  (is (nil? (lt/birth-date "33313240064"))))

(deftest non-strings
  (is (false? (lt/personal-code? nil)))
  (is (false? (lt/iban? 42))))
