import 'package:packme/packme.dart';

enum TestEnum {
	one,
	two,
	three,
}

class NestedObject extends PackMeMessage {
	NestedObject({
		required this.a,
		required this.b,
	});
	NestedObject.$empty();

	late int a;
	late String b;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 1;
		bytes += $stringBytes(b);
		return bytes;
	}

	@override
	void $pack() {
		$packUint8(a);
		$packString(b);
	}

	@override
	void $unpack() {
		a = $unpackUint8();
		b = $unpackString();
	}

	@override
	String toString() {
		return 'NestedObject\x1b[0m(a: ${PackMe.dye(a)}, b: ${PackMe.dye(b)})';
	}
}

class TestMessage extends PackMeMessage {
	TestMessage({
		required this.reqInt8,
		required this.reqUint8,
		required this.reqInt16,
		required this.reqUint16,
		required this.reqInt32,
		required this.reqUint32,
		required this.reqInt64,
		required this.reqUint64,
		required this.reqFloat,
		required this.reqDouble,
		required this.reqBool,
		required this.reqString,
		required this.reqList,
		required this.reqEnum,
		required this.reqNested,
		this.optInt8,
		this.optUint8,
		this.optInt16,
		this.optUint16,
		this.optInt32,
		this.optUint32,
		this.optInt64,
		this.optUint64,
		this.optFloat,
		this.optDouble,
		this.optBool,
		this.optString,
		this.optList,
		this.optEnum,
		this.optNested,
	});
	TestMessage.$empty();

	late int reqInt8;
	late int reqUint8;
	late int reqInt16;
	late int reqUint16;
	late int reqInt32;
	late int reqUint32;
	late int reqInt64;
	late int reqUint64;
	late double reqFloat;
	late double reqDouble;
	late bool reqBool;
	late String reqString;
	late List<int> reqList;
	late TestEnum reqEnum;
	late NestedObject reqNested;
	int? optInt8;
	int? optUint8;
	int? optInt16;
	int? optUint16;
	int? optInt32;
	int? optUint32;
	int? optInt64;
	int? optUint64;
	double? optFloat;
	double? optDouble;
	bool? optBool;
	String? optString;
	List<int>? optList;
	TestEnum? optEnum;
	NestedObject? optNested;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 54;
		bytes += $stringBytes(reqString);
		bytes += 4;
		bytes += 1 * reqList.length;
		bytes += reqNested.$estimate();
		$setFlag(optInt8 != null);
		if (optInt8 != null) {
			bytes += 1;
		}
		$setFlag(optUint8 != null);
		if (optUint8 != null) {
			bytes += 1;
		}
		$setFlag(optInt16 != null);
		if (optInt16 != null) {
			bytes += 2;
		}
		$setFlag(optUint16 != null);
		if (optUint16 != null) {
			bytes += 2;
		}
		$setFlag(optInt32 != null);
		if (optInt32 != null) {
			bytes += 4;
		}
		$setFlag(optUint32 != null);
		if (optUint32 != null) {
			bytes += 4;
		}
		$setFlag(optInt64 != null);
		if (optInt64 != null) {
			bytes += 8;
		}
		$setFlag(optUint64 != null);
		if (optUint64 != null) {
			bytes += 8;
		}
		$setFlag(optFloat != null);
		if (optFloat != null) {
			bytes += 4;
		}
		$setFlag(optDouble != null);
		if (optDouble != null) {
			bytes += 8;
		}
		$setFlag(optBool != null);
		if (optBool != null) {
			bytes += 1;
		}
		$setFlag(optString != null);
		if (optString != null) {
			bytes += $stringBytes(optString!);
		}
		$setFlag(optList != null);
		if (optList != null) {
			bytes += 4;
			bytes += 1 * optList!.length;
		}
		$setFlag(optEnum != null);
		if (optEnum != null) {
			bytes += 1;
		}
		$setFlag(optNested != null);
		if (optNested != null) {
			bytes += optNested!.$estimate();
		}
		return bytes;
	}

	@override
	void $pack() {
		$initPack(184530025);
		for (int i = 0; i < 2; i++) $packUint8($flags[i]);
		$packInt8(reqInt8);
		$packUint8(reqUint8);
		$packInt16(reqInt16);
		$packUint16(reqUint16);
		$packInt32(reqInt32);
		$packUint32(reqUint32);
		$packInt64(reqInt64);
		$packUint64(reqUint64);
		$packFloat(reqFloat);
		$packDouble(reqDouble);
		$packBool(reqBool);
		$packString(reqString);
		$packUint32(reqList.length);
		for (final int item in reqList) $packUint8(item);
		$packUint8(reqEnum.index);
		$packMessage(reqNested);
		if (optInt8 != null) $packInt8(optInt8!);
		if (optUint8 != null) $packUint8(optUint8!);
		if (optInt16 != null) $packInt16(optInt16!);
		if (optUint16 != null) $packUint16(optUint16!);
		if (optInt32 != null) $packInt32(optInt32!);
		if (optUint32 != null) $packUint32(optUint32!);
		if (optInt64 != null) $packInt64(optInt64!);
		if (optUint64 != null) $packUint64(optUint64!);
		if (optFloat != null) $packFloat(optFloat!);
		if (optDouble != null) $packDouble(optDouble!);
		if (optBool != null) $packBool(optBool!);
		if (optString != null) $packString(optString!);
		if (optList != null) {
			$packUint32(optList!.length);
			for (final int item in optList!) $packUint8(item);
		}
		if (optEnum != null) $packUint8(optEnum!.index);
		if (optNested != null) $packMessage(optNested!);
	}

	@override
	void $unpack() {
		$initUnpack();
		for (int i = 0; i < 2; i++) $flags.add($unpackUint8());
		reqInt8 = $unpackInt8();
		reqUint8 = $unpackUint8();
		reqInt16 = $unpackInt16();
		reqUint16 = $unpackUint16();
		reqInt32 = $unpackInt32();
		reqUint32 = $unpackUint32();
		reqInt64 = $unpackInt64();
		reqUint64 = $unpackUint64();
		reqFloat = $unpackFloat();
		reqDouble = $unpackDouble();
		reqBool = $unpackBool();
		reqString = $unpackString();
		reqList = <int>[];
		final int reqListLength = $unpackUint32();
		for (int i = 0; i < reqListLength; i++) {
			reqList.add($unpackUint8());
		}
		reqEnum = TestEnum.values[$unpackUint8()];
		reqNested = $unpackMessage(NestedObject.$empty());
		if ($getFlag()) {
			optInt8 = $unpackInt8();
		}
		if ($getFlag()) {
			optUint8 = $unpackUint8();
		}
		if ($getFlag()) {
			optInt16 = $unpackInt16();
		}
		if ($getFlag()) {
			optUint16 = $unpackUint16();
		}
		if ($getFlag()) {
			optInt32 = $unpackInt32();
		}
		if ($getFlag()) {
			optUint32 = $unpackUint32();
		}
		if ($getFlag()) {
			optInt64 = $unpackInt64();
		}
		if ($getFlag()) {
			optUint64 = $unpackUint64();
		}
		if ($getFlag()) {
			optFloat = $unpackFloat();
		}
		if ($getFlag()) {
			optDouble = $unpackDouble();
		}
		if ($getFlag()) {
			optBool = $unpackBool();
		}
		if ($getFlag()) {
			optString = $unpackString();
		}
		if ($getFlag()) {
			optList = <int>[];
			final int optListLength = $unpackUint32();
			for (int i = 0; i < optListLength; i++) {
				optList!.add($unpackUint8());
			}
		}
		if ($getFlag()) {
			optEnum = TestEnum.values[$unpackUint8()];
		}
		if ($getFlag()) {
			optNested = $unpackMessage(NestedObject.$empty());
		}
	}

	@override
	String toString() {
		return 'TestMessage\x1b[0m(reqInt8: ${PackMe.dye(reqInt8)}, reqUint8: ${PackMe.dye(reqUint8)}, reqInt16: ${PackMe.dye(reqInt16)}, reqUint16: ${PackMe.dye(reqUint16)}, reqInt32: ${PackMe.dye(reqInt32)}, reqUint32: ${PackMe.dye(reqUint32)}, reqInt64: ${PackMe.dye(reqInt64)}, reqUint64: ${PackMe.dye(reqUint64)}, reqFloat: ${PackMe.dye(reqFloat)}, reqDouble: ${PackMe.dye(reqDouble)}, reqBool: ${PackMe.dye(reqBool)}, reqString: ${PackMe.dye(reqString)}, reqList: ${PackMe.dye(reqList)}, reqEnum: ${PackMe.dye(reqEnum)}, reqNested: ${PackMe.dye(reqNested)}, optInt8: ${PackMe.dye(optInt8)}, optUint8: ${PackMe.dye(optUint8)}, optInt16: ${PackMe.dye(optInt16)}, optUint16: ${PackMe.dye(optUint16)}, optInt32: ${PackMe.dye(optInt32)}, optUint32: ${PackMe.dye(optUint32)}, optInt64: ${PackMe.dye(optInt64)}, optUint64: ${PackMe.dye(optUint64)}, optFloat: ${PackMe.dye(optFloat)}, optDouble: ${PackMe.dye(optDouble)}, optBool: ${PackMe.dye(optBool)}, optString: ${PackMe.dye(optString)}, optList: ${PackMe.dye(optList)}, optEnum: ${PackMe.dye(optEnum)}, optNested: ${PackMe.dye(optNested)})';
	}
}

final Map<int, PackMeMessage Function()> packmeTestMessageFactory = <int, PackMeMessage Function()>{
	184530025: () => TestMessage.$empty(),
};