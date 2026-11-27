(ns ltcodes.core
  "Validate Lithuanian personal codes, company codes, VAT numbers and IBANs.

  A valid check digit only proves that a code is well formed, not that it was
  issued to anyone."
  (:require [clojure.string :as str]))

(defn- digits
  "The digits of s as a vector of ints, or nil if s is empty or has a non-digit."
  [s]
  (when (and (string? s) (re-matches #"[0-9]+" s))
    (mapv #(Character/digit ^char % 10) s)))

(defn- check-digit
  "The shared check digit rule: weights 1 to 9, then 3 to 9, 1, 2 if the first
  pass gives 10."
  [d]
  (let [pass (fn [shift]
               (mod (reduce + (map-indexed (fn [i n] (* n (inc (mod (+ i shift) 9)))) d))
                    11))
        first-pass (pass 0)]
    (if (not= first-pass 10)
      first-pass
      (mod (pass 2) 10))))

(defn- leap? [y]
  (or (and (zero? (mod y 4)) (pos? (mod y 100))) (zero? (mod y 400))))

(defn- days-in-month [y m]
  (case (int m)
    (1 3 5 7 8 10 12) 31
    (4 6 9 11) 30
    2 (if (leap? y) 29 28)
    0))

(defn birth-date
  "The birth date in a personal code as [year month day], or nil when the code
  has no valid date or starts with 9 and so carries no date at all."
  [code]
  (when-let [d (digits code)]
    (when (= 11 (count d))
      (when-let [century (case (int (d 0)) (1 2) 1800 (3 4) 1900 (5 6) 2000 nil)]
        (let [y (+ century (* 10 (d 1)) (d 2))
              m (+ (* 10 (d 3)) (d 4))
              day (+ (* 10 (d 5)) (d 6))]
          (when (<= 1 day (days-in-month y m))
            [y m day]))))))

(defn personal-code?
  "Tests a personal code (asmens kodas)."
  [code]
  (boolean
   (when-let [d (digits code)]
     (and (= 11 (count d))
          (or (= 9 (d 0)) (some? (birth-date code)))
          (= (check-digit (subvec d 0 10)) (d 10))))))

(defn company-code?
  "Tests a company code (juridinio asmens kodas)."
  [code]
  (boolean
   (when-let [d (digits code)]
     (and (= 9 (count d))
          (= (check-digit (subvec d 0 8)) (d 8))))))

(defn- compact [s]
  (when (string? s)
    (str/upper-case (str/replace s #"[\s-]" ""))))

(defn vat-number?
  "Tests a VAT number (PVM moketojo kodas), with or without the LT prefix."
  [code]
  (boolean
   (when-let [c (compact code)]
     (let [c (if (str/starts-with? c "LT") (subs c 2) c)]
       (when-let [d (digits c)]
         (when-let [marker (case (count d) 9 7 12 10 nil)]
           (and (= 1 (d marker))
                (= (check-digit (subvec d 0 (dec (count d)))) (peek d)))))))))

(defn iban?
  "Tests a Lithuanian IBAN: 20 characters, the LT prefix and the MOD-97 rule."
  [code]
  (boolean
   (when-let [c (compact code)]
     (when (and (= 20 (count c)) (str/starts-with? c "LT"))
       (let [rearranged (str (subs c 4) (subs c 0 4))
             values (map #(Character/digit ^char % 36) rearranged)]
         (when (every? #(>= % 0) values)
           (= 1 (reduce (fn [rem v] (if (> v 9) (mod (+ (* rem 100) v) 97) (mod (+ (* rem 10) v) 97)))
                        0 values))))))))
