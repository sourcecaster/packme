import 'dart:typed_data';
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
		int _bytes = 1;
		_bytes += $stringBytes(b);
		return _bytes;
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

class SubObject extends NestedObject {
	SubObject({
		required int a,
		required String b,
		required this.c,
	}) : super(a: a, b: b);
	SubObject.$empty() : super.$empty();

	late double c;

	@override
	int $estimate() {
		int _bytes = super.$estimate();
		_bytes += 8;
		return _bytes;
	}

	@override
	void $pack() {
		super.$pack();
		$packDouble(c);
	}

	@override
	void $unpack() {
		super.$unpack();
		c = $unpackDouble();
	}

	@override
	String toString() {
		return 'SubObject\x1b[0m(c: ${PackMe.dye(c)}) of ${super.toString()}';
	}
}

class TestMessage extends PackMeMessage {
	TestMessage({
		required this.reqId,
		this.optId,
		required this.reqIds,
		this.optIds,
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
		required this.reqNestedList,
		required this.reqInherited,
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
		this.optNestedList,
		this.optInherited,
	});
	TestMessage.$empty();

	late Uint8List reqId;
	Uint8List? optId;
	late List<Uint8List> reqIds;
	List<Uint8List>? optIds;
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
	late List<List<int>> reqNestedList;
	late SubObject reqInherited;
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
	List<List<int>>? optNestedList;
	SubObject? optInherited;

	@override
	int $estimate() {
		$reset();
		int _bytes = 67;
		$setFlag(optId != null);
		if (optId != null) _bytes += 12;
		_bytes += 4 + reqIds.length * 4;
		$setFlag(optIds != null);
		if (optIds != null) _bytes += 4 + optIds!.fold(0, (int a, Uint8List b) => a + 4);
		_bytes += $stringBytes(reqString);
		_bytes += 4 + reqList.length * 1;
		_bytes += reqNested.$estimate();
		_bytes += 4 + reqNestedList.fold(0, (int a, List<int> b) => a + 4 + b.length * 4);
		_bytes += reqInherited.$estimate();
		$setFlag(optInt8 != null);
		if (optInt8 != null) _bytes += 1;
		$setFlag(optUint8 != null);
		if (optUint8 != null) _bytes += 1;
		$setFlag(optInt16 != null);
		if (optInt16 != null) _bytes += 2;
		$setFlag(optUint16 != null);
		if (optUint16 != null) _bytes += 2;
		$setFlag(optInt32 != null);
		if (optInt32 != null) _bytes += 4;
		$setFlag(optUint32 != null);
		if (optUint32 != null) _bytes += 4;
		$setFlag(optInt64 != null);
		if (optInt64 != null) _bytes += 8;
		$setFlag(optUint64 != null);
		if (optUint64 != null) _bytes += 8;
		$setFlag(optFloat != null);
		if (optFloat != null) _bytes += 4;
		$setFlag(optDouble != null);
		if (optDouble != null) _bytes += 8;
		$setFlag(optBool != null);
		if (optBool != null) _bytes += 1;
		$setFlag(optString != null);
		if (optString != null) _bytes += $stringBytes(optString!);
		$setFlag(optList != null);
		if (optList != null) _bytes += 4 + optList!.fold(0, (int a, int b) => a + 1);
		$setFlag(optEnum != null);
		if (optEnum != null) _bytes += 1;
		$setFlag(optNested != null);
		if (optNested != null) _bytes += optNested!.$estimate();
		$setFlag(optNestedList != null);
		if (optNestedList != null) _bytes += 4 + optNestedList!.fold(0, (int a, List<int> b) => a + 4 + b.fold(0, (int a, int b) => a + 4));
		$setFlag(optInherited != null);
		if (optInherited != null) _bytes += optInherited!.$estimate();
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(184530025);
		for (int i = 0; i < 3; i++) $packUint8($flags[i]);
		$packBinary(reqId, 12);
		if (optId != null) $packBinary(optId!, 12);
		$packUint32(reqIds.length);
		for (int _i6 = 0; _i6 < reqIds.length; _i6++) {
			$packBinary(reqIds[_i6], 4);
		}
		if (optIds != null) {
			$packUint32(optIds!.length);
			for (int _i7 = 0; _i7 < optIds!.length; _i7++) {
				$packBinary(optIds![_i7], 4);
			}
		}
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
		for (int _i7 = 0; _i7 < reqList.length; _i7++) {
			$packUint8(reqList[_i7]);
		}
		$packUint8(reqEnum.index);
		$packMessage(reqNested);
		$packUint32(reqNestedList.length);
		for (int _i13 = 0; _i13 < reqNestedList.length; _i13++) {
			$packUint32(reqNestedList[_i13].length);
			for (int _i19 = 0; _i19 < reqNestedList[_i13].length; _i19++) {
				$packInt32(reqNestedList[_i13][_i19]);
			}
		}
		$packMessage(reqInherited);
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
			for (int _i8 = 0; _i8 < optList!.length; _i8++) {
				$packUint8(optList![_i8]);
			}
		}
		if (optEnum != null) $packUint8(optEnum!.index);
		if (optNested != null) $packMessage(optNested!);
		if (optNestedList != null) {
			$packUint32(optNestedList!.length);
			for (int _i14 = 0; _i14 < optNestedList!.length; _i14++) {
				$packUint32(optNestedList![_i14].length);
				for (int _i20 = 0; _i20 < optNestedList![_i14].length; _i20++) {
					$packInt32(optNestedList![_i14][_i20]);
				}
			}
		}
		if (optInherited != null) $packMessage(optInherited!);
	}

	@override
	void $unpack() {
		$initUnpack();
		for (int i = 0; i < 3; i++) $flags.add($unpackUint8());
		reqId = $unpackBinary(12);
		if ($getFlag()) optId = $unpackBinary(12);
		reqIds = List<Uint8List>.generate($unpackUint32(), (int i) {
			return $unpackBinary(4);
		});
		if ($getFlag()) {
			optIds = List<Uint8List>.generate($unpackUint32(), (int i) {
				return $unpackBinary(4);
			});
		}
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
		reqList = List<int>.generate($unpackUint32(), (int i) {
			return $unpackUint8();
		});
		reqEnum = TestEnum.values[$unpackUint8()];
		reqNested = $unpackMessage(NestedObject.$empty());
		reqNestedList = List<List<int>>.generate($unpackUint32(), (int i) {
			return List<int>.generate($unpackUint32(), (int i) {
				return $unpackInt32();
			});
		});
		reqInherited = $unpackMessage(SubObject.$empty());
		if ($getFlag()) optInt8 = $unpackInt8();
		if ($getFlag()) optUint8 = $unpackUint8();
		if ($getFlag()) optInt16 = $unpackInt16();
		if ($getFlag()) optUint16 = $unpackUint16();
		if ($getFlag()) optInt32 = $unpackInt32();
		if ($getFlag()) optUint32 = $unpackUint32();
		if ($getFlag()) optInt64 = $unpackInt64();
		if ($getFlag()) optUint64 = $unpackUint64();
		if ($getFlag()) optFloat = $unpackFloat();
		if ($getFlag()) optDouble = $unpackDouble();
		if ($getFlag()) optBool = $unpackBool();
		if ($getFlag()) optString = $unpackString();
		if ($getFlag()) {
			optList = List<int>.generate($unpackUint32(), (int i) {
				return $unpackUint8();
			});
		}
		if ($getFlag()) optEnum = TestEnum.values[$unpackUint8()];
		if ($getFlag()) optNested = $unpackMessage(NestedObject.$empty());
		if ($getFlag()) {
			optNestedList = List<List<int>>.generate($unpackUint32(), (int i) {
				return List<int>.generate($unpackUint32(), (int i) {
					return $unpackInt32();
				});
			});
		}
		if ($getFlag()) optInherited = $unpackMessage(SubObject.$empty());
	}

	@override
	String toString() {
		return 'TestMessage\x1b[0m(reqId: ${PackMe.dye(reqId)}, optId: ${PackMe.dye(optId)}, reqIds: ${PackMe.dye(reqIds)}, optIds: ${PackMe.dye(optIds)}, reqInt8: ${PackMe.dye(reqInt8)}, reqUint8: ${PackMe.dye(reqUint8)}, reqInt16: ${PackMe.dye(reqInt16)}, reqUint16: ${PackMe.dye(reqUint16)}, reqInt32: ${PackMe.dye(reqInt32)}, reqUint32: ${PackMe.dye(reqUint32)}, reqInt64: ${PackMe.dye(reqInt64)}, reqUint64: ${PackMe.dye(reqUint64)}, reqFloat: ${PackMe.dye(reqFloat)}, reqDouble: ${PackMe.dye(reqDouble)}, reqBool: ${PackMe.dye(reqBool)}, reqString: ${PackMe.dye(reqString)}, reqList: ${PackMe.dye(reqList)}, reqEnum: ${PackMe.dye(reqEnum)}, reqNested: ${PackMe.dye(reqNested)}, reqNestedList: ${PackMe.dye(reqNestedList)}, reqInherited: ${PackMe.dye(reqInherited)}, optInt8: ${PackMe.dye(optInt8)}, optUint8: ${PackMe.dye(optUint8)}, optInt16: ${PackMe.dye(optInt16)}, optUint16: ${PackMe.dye(optUint16)}, optInt32: ${PackMe.dye(optInt32)}, optUint32: ${PackMe.dye(optUint32)}, optInt64: ${PackMe.dye(optInt64)}, optUint64: ${PackMe.dye(optUint64)}, optFloat: ${PackMe.dye(optFloat)}, optDouble: ${PackMe.dye(optDouble)}, optBool: ${PackMe.dye(optBool)}, optString: ${PackMe.dye(optString)}, optList: ${PackMe.dye(optList)}, optEnum: ${PackMe.dye(optEnum)}, optNested: ${PackMe.dye(optNested)}, optNestedList: ${PackMe.dye(optNestedList)}, optInherited: ${PackMe.dye(optInherited)})';
	}
}

final Map<int, PackMeMessage Function()> packmeTestMessageFactory = <int, PackMeMessage Function()>{
	184530025: () => TestMessage.$empty(),
};