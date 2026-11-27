(ns build
  (:require [clojure.tools.build.api :as b]
            [deps-deploy.deps-deploy :as dd]))

(def lib 'net.clojars.ellolt/ltcodes)
(def version "1.0.0")
(def class-dir "target/classes")
(def jar-file (format "target/%s-%s.jar" (name lib) version))

(defn- pom-data []
  [[:description "Validate Lithuanian personal codes, company codes, VAT numbers and IBANs."]
   [:url "https://kokybiskasvetaine.lt/"]
   [:licenses [:license [:name "MIT"] [:url "https://opensource.org/license/mit"]]]
   [:developers [:developer [:name "Justas Arbatauskis"] [:url "https://kokybiskasvetaine.lt/"]]]
   [:organization [:name "KokybiskaSvetaine.lt"] [:url "https://kokybiskasvetaine.lt/"]]])

(defn jar [_]
  (b/delete {:path "target"})
  (b/write-pom {:class-dir class-dir
                :lib lib
                :version version
                :basis (b/create-basis {:project "deps.edn"})
                :src-dirs ["src"]
                :scm {:url "https://github.com/ello-lithuania/ltcodes"
                      :connection "scm:git:https://github.com/ello-lithuania/ltcodes.git"
                      :tag (str "clojure-v" version)}
                :pom-data (pom-data)})
  (b/copy-dir {:src-dirs ["src"] :target-dir class-dir})
  (b/jar {:class-dir class-dir :jar-file jar-file}))

(defn deploy [_]
  (jar nil)
  (dd/deploy {:installer :remote
              :artifact (b/resolve-path jar-file)
              :pom-file (b/pom-path {:lib lib :class-dir class-dir})}))
