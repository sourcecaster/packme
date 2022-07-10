import 'dart:typed_data';
import 'package:packme/packme.dart';

enum TypeEnum {
	one,
	two,
	four,
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
		required this.reqId,
		this.optId,
		required this.reqIds,
		this.optIds,
		required this.reqInt8,
		required this.reqUint16,
		required this.reqDouble,
		required this.reqBool,
		required this.reqString,
		this.optInt8,
		this.optUint16,
		this.optDouble,
		this.optBool,
		this.optString,
		required this.reqList,
		this.optList,
		required this.reqEnum,
		this.optEnum,
		required this.reqNested,
		this.optNested,
	});
	TestMessage.$empty();

	late Uint8List reqId;
	Uint8List? optId;
	late List<Uint8List> reqIds;
	List<Uint8List>? optIds;
	late int reqInt8;
	late int reqUint16;
	late double reqDouble;
	late bool reqBool;
	late String reqString;
	int? optInt8;
	int? optUint16;
	double? optDouble;
	bool? optBool;
	String? optString;
	late List<int> reqList;
	List<int>? optList;
	late TypeEnum reqEnum;
	TypeEnum? optEnum;
	late NestedObject reqNested;
	NestedObject? optNested;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 35;
		$setFlag(optId != null);
		if (optId != null) {
			bytes += 12;
		}
		bytes += 4;
		bytes += 4 * reqIds.length;
		$setFlag(optIds != null);
		if (optIds != null) {
			bytes += 4;
			bytes += 4 * optIds!.length;
		}
		bytes += $stringBytes(reqString);
		$setFlag(optInt8 != null);
		if (optInt8 != null) {
			bytes += 1;
		}
		$setFlag(optUint16 != null);
		if (optUint16 != null) {
			bytes += 2;
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
		bytes += 4;
		bytes += 1 * reqList.length;
		$setFlag(optList != null);
		if (optList != null) {
			bytes += 4;
			bytes += 1 * optList!.length;
		}
		$setFlag(optEnum != null);
		if (optEnum != null) {
			bytes += 1;
		}
		bytes += reqNested.$estimate();
		$setFlag(optNested != null);
		if (optNested != null) {
			bytes += optNested!.$estimate();
		}
		return bytes;
	}

	@override
	void $pack() {
		$initPack(475203406);
		for (int i = 0; i < 2; i++) $packUint8($flags[i]);
		$packBinary(reqId, 12);
		if (optId != null) $packBinary(optId!, 12);
		$packUint32(reqIds.length);
		for (final Uint8List item in reqIds) $packBinary(item, 4);
		if (optIds != null) {
			$packUint32(optIds!.length);
			for (final Uint8List item in optIds!) $packBinary(item, 4);
		}
		$packInt8(reqInt8);
		$packUint16(reqUint16);
		$packDouble(reqDouble);
		$packBool(reqBool);
		$packString(reqString);
		if (optInt8 != null) $packInt8(optInt8!);
		if (optUint16 != null) $packUint16(optUint16!);
		if (optDouble != null) $packDouble(optDouble!);
		if (optBool != null) $packBool(optBool!);
		if (optString != null) $packString(optString!);
		$packUint32(reqList.length);
		for (final int item in reqList) $packUint8(item);
		if (optList != null) {
			$packUint32(optList!.length);
			for (final int item in optList!) $packUint8(item);
		}
		$packUint8(reqEnum.index);
		if (optEnum != null) $packUint8(optEnum!.index);
		$packMessage(reqNested);
		if (optNested != null) $packMessage(optNested!);
	}

	@override
	void $unpack() {
		$initUnpack();
		for (int i = 0; i < 2; i++) $flags.add($unpackUint8());
		reqId = $unpackBinary(12);
		if ($getFlag()) {
			optId = $unpackBinary(12);
		}
		reqIds = <Uint8List>[];
		final int reqIdsLength = $unpackUint32();
		for (int i = 0; i < reqIdsLength; i++) {
			reqIds.add($unpackBinary(4));
		}
		if ($getFlag()) {
			optIds = <Uint8List>[];
			final int optIdsLength = $unpackUint32();
			for (int i = 0; i < optIdsLength; i++) {
				optIds!.add($unpackBinary(4));
			}
		}
		reqInt8 = $unpackInt8();
		reqUint16 = $unpackUint16();
		reqDouble = $unpackDouble();
		reqBool = $unpackBool();
		reqString = $unpackString();
		if ($getFlag()) {
			optInt8 = $unpackInt8();
		}
		if ($getFlag()) {
			optUint16 = $unpackUint16();
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
		reqList = <int>[];
		final int reqListLength = $unpackUint32();
		for (int i = 0; i < reqListLength; i++) {
			reqList.add($unpackUint8());
		}
		if ($getFlag()) {
			optList = <int>[];
			final int optListLength = $unpackUint32();
			for (int i = 0; i < optListLength; i++) {
				optList!.add($unpackUint8());
			}
		}
		reqEnum = TypeEnum.values[$unpackUint8()];
		if ($getFlag()) {
			optEnum = TypeEnum.values[$unpackUint8()];
		}
		reqNested = $unpackMessage(NestedObject.$empty());
		if ($getFlag()) {
			optNested = $unpackMessage(NestedObject.$empty());
		}
	}

	@override
	String toString() {
		return 'TestMessage\x1b[0m(reqId: ${PackMe.dye(reqId)}, optId: ${PackMe.dye(optId)}, reqIds: ${PackMe.dye(reqIds)}, optIds: ${PackMe.dye(optIds)}, reqInt8: ${PackMe.dye(reqInt8)}, reqUint16: ${PackMe.dye(reqUint16)}, reqDouble: ${PackMe.dye(reqDouble)}, reqBool: ${PackMe.dye(reqBool)}, reqString: ${PackMe.dye(reqString)}, optInt8: ${PackMe.dye(optInt8)}, optUint16: ${PackMe.dye(optUint16)}, optDouble: ${PackMe.dye(optDouble)}, optBool: ${PackMe.dye(optBool)}, optString: ${PackMe.dye(optString)}, reqList: ${PackMe.dye(reqList)}, optList: ${PackMe.dye(optList)}, reqEnum: ${PackMe.dye(reqEnum)}, optEnum: ${PackMe.dye(optEnum)}, reqNested: ${PackMe.dye(reqNested)}, optNested: ${PackMe.dye(optNested)})';
	}
}

final Map<int, PackMeMessage Function()> exampleMessageFactory = <int, PackMeMessage Function()>{
	475203406: () => TestMessage.$empty(),
};