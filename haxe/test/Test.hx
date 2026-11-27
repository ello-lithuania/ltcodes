import ltcodes.LtCodes;

class Test {
	static var failures = 0;

	static function check(vectors:Dynamic, kind:String, f:String->Bool) {
		var group:Dynamic = Reflect.field(vectors, kind);
		for (c in (group.valid : Array<String>))
			if (!f(c)) {
				failures++;
				Sys.println('FAIL $kind valid: "$c"');
			}
		for (c in (group.invalid : Array<String>))
			if (f(c)) {
				failures++;
				Sys.println('FAIL $kind invalid: "$c"');
			}
	}

	static function main() {
		var vectors = haxe.Json.parse(sys.io.File.getContent("../test_vectors.json"));
		check(vectors, "personal", LtCodes.isPersonalCode);
		check(vectors, "company", LtCodes.isCompanyCode);
		check(vectors, "vat", LtCodes.isVatNumber);
		check(vectors, "iban", LtCodes.isIban);
		var bd = LtCodes.birthDate("33309240064");
		if (bd == null || bd.join("-") != "1933-9-24") {
			failures++;
			Sys.println("FAIL birthDate");
		}
		if (LtCodes.birthDate("90000000009") != null || LtCodes.isIban(null)) {
			failures++;
			Sys.println("FAIL null cases");
		}
		Sys.println(failures == 0 ? "All tests passed" : '$failures failures');
		Sys.exit(failures == 0 ? 0 : 1);
	}
}
