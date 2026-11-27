package ltcodes;

/**
	Validate Lithuanian personal codes, company codes, VAT numbers and IBANs.

	A valid check digit only proves that a code is well formed, not that it was
	issued to anyone.
**/
class LtCodes {
	static function digits(s:String):Null<Array<Int>> {
		if (s == null || s.length == 0)
			return null;
		var d = [];
		for (i in 0...s.length) {
			var c:Int = s.charCodeAt(i);
			if (c < 48 || c > 57)
				return null;
			d.push(c - 48);
		}
		return d;
	}

	/** The shared check digit rule: weights 1 to 9, then 3 to 9, 1, 2 if the first pass gives 10. **/
	static function checkDigit(d:Array<Int>):Int {
		function pass(shift:Int):Int {
			var sum = 0;
			for (i in 0...d.length)
				sum += (1 + ((i + shift) % 9)) * d[i];
			return sum % 11;
		}
		var first = pass(0);
		return first != 10 ? first : pass(2) % 10;
	}

	static function daysInMonth(y:Int, m:Int):Int {
		return switch (m) {
			case 1, 3, 5, 7, 8, 10, 12: 31;
			case 4, 6, 9, 11: 30;
			case 2: ((y % 4 == 0 && y % 100 != 0) || y % 400 == 0) ? 29 : 28;
			default: 0;
		}
	}

	/**
		The birth date in a personal code as `[year, month, day]`, or `null` when
		the code has no valid date or starts with 9 and so carries no date at all.
	**/
	public static function birthDate(code:String):Null<Array<Int>> {
		var d = digits(code);
		if (d == null || d.length != 11)
			return null;
		var century = switch (d[0]) {
			case 1, 2: 1800;
			case 3, 4: 1900;
			case 5, 6: 2000;
			default: return null;
		}
		var y = century + d[1] * 10 + d[2];
		var m = d[3] * 10 + d[4];
		var day = d[5] * 10 + d[6];
		if (day < 1 || day > daysInMonth(y, m))
			return null;
		return [y, m, day];
	}

	/** Tests a personal code (asmens kodas). **/
	public static function isPersonalCode(code:String):Bool {
		var d = digits(code);
		if (d == null || d.length != 11)
			return false;
		if (d[0] != 9 && birthDate(code) == null)
			return false;
		return checkDigit(d.slice(0, 10)) == d[10];
	}

	/** Tests a company code (juridinio asmens kodas). **/
	public static function isCompanyCode(code:String):Bool {
		var d = digits(code);
		return d != null && d.length == 9 && checkDigit(d.slice(0, 8)) == d[8];
	}

	static function compact(s:String):Null<String> {
		if (s == null)
			return null;
		return ~/[\s-]/g.replace(s, "").toUpperCase();
	}

	/** Tests a VAT number (PVM moketojo kodas), with or without the LT prefix. **/
	public static function isVatNumber(code:String):Bool {
		var c = compact(code);
		if (c == null)
			return false;
		if (StringTools.startsWith(c, "LT"))
			c = c.substr(2);
		var d = digits(c);
		if (d == null)
			return false;
		var marker = switch (d.length) {
			case 9: 7;
			case 12: 10;
			default: return false;
		}
		return d[marker] == 1 && checkDigit(d.slice(0, d.length - 1)) == d[d.length - 1];
	}

	/** Tests a Lithuanian IBAN: 20 characters, the LT prefix and the MOD-97 rule. **/
	public static function isIban(code:String):Bool {
		var c = compact(code);
		if (c == null || c.length != 20 || !StringTools.startsWith(c, "LT"))
			return false;
		var s = c.substr(4) + c.substr(0, 4);
		var rem = 0;
		for (i in 0...s.length) {
			var ch:Int = s.charCodeAt(i);
			var v = if (ch >= 48 && ch <= 57) ch - 48 else if (ch >= 65 && ch <= 90) ch - 55 else -1;
			if (v < 0)
				return false;
			rem = v > 9 ? (rem * 100 + v) % 97 : (rem * 10 + v) % 97;
		}
		return rem == 1;
	}
}
