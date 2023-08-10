import 'dart:typed_data';
import 'package:packme/packme.dart';

enum HalfLifeVersion {
	one,
	two,
	four,
}

class InfoEntity extends PackMeMessage {
	InfoEntity({
		required this.string,
		required this.value,
		required this.flag,
		required this.version,
	});
	InfoEntity.$empty();

	late String string;
	late int value;
	late bool flag;
	late HalfLifeVersion version;


	@override
	int $estimate() {
		$reset();
		int _bytes = 6;
		_bytes += $stringBytes(string);
		return _bytes;
	}

	@override
	void $pack() {
		$packString(string);
		$packUint32(value);
		$packBool(flag);
		$packUint8(version.index);
	}

	@override
	void $unpack() {
		string = $unpackString();
		value = $unpackUint32();
		flag = $unpackBool();
		version = HalfLifeVersion.values[$unpackUint8()];
	}

	@override
	String toString() {
		return 'InfoEntity\x1b[0m(string: ${PackMe.dye(string)}, value: ${PackMe.dye(value)}, flag: ${PackMe.dye(flag)}, version: ${PackMe.dye(version)})';
	}
}

class GetDataResponseItem extends PackMeMessage {
	GetDataResponseItem({
		this.string,
		this.value,
		this.flag,
		this.version,
	});
	GetDataResponseItem.$empty();

	String? string;
	int? value;
	bool? flag;
	HalfLifeVersion? version;


	@override
	int $estimate() {
		$reset();
		int _bytes = 1;
		$setFlag(string != null);
		if (string != null) _bytes += $stringBytes(string!);
		$setFlag(value != null);
		if (value != null) _bytes += 4;
		$setFlag(flag != null);
		if (flag != null) _bytes += 1;
		$setFlag(version != null);
		if (version != null) _bytes += 1;
		return _bytes;
	}

	@override
	void $pack() {
		for (int i = 0; i < 1; i++) $packUint8($flags[i]);
		if (string != null) $packString(string!);
		if (value != null) $packUint32(value!);
		if (flag != null) $packBool(flag!);
		if (version != null) $packUint8(version!.index);
	}

	@override
	void $unpack() {
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		if ($getFlag()) string = $unpackString();
		if ($getFlag()) value = $unpackUint32();
		if ($getFlag()) flag = $unpackBool();
		if ($getFlag()) version = HalfLifeVersion.values[$unpackUint8()];
	}

	@override
	String toString() {
		return 'GetDataResponseItem\x1b[0m(string: ${PackMe.dye(string)}, value: ${PackMe.dye(value)}, flag: ${PackMe.dye(flag)}, version: ${PackMe.dye(version)})';
	}
}

class SendInfoMessage extends PackMeMessage {
	SendInfoMessage({
		required this.id,
		required this.notes,
		required this.version,
		required this.entity,
	});
	SendInfoMessage.$empty();

	late List<int> id;
	late List<String> notes;
	late HalfLifeVersion version;
	late InfoEntity entity;


	@override
	int $estimate() {
		$reset();
		int _bytes = 9;
		_bytes += 4 + id.length * 1;
		_bytes += 4 + notes.fold(0, (int a, String b) => a + $stringBytes(b));
		_bytes += entity.$estimate();
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(511521838);
		$packUint32(id.length);
		for (int i = 0; i < id.length; i++) $packUint8(id[i]);
		$packUint32(notes.length);
		for (int i = 0; i < notes.length; i++) $packString(notes[i]);
		$packUint8(version.index);
		$packMessage(entity);
	}

	@override
	void $unpack() {
		$initUnpack();
		id = <int>[];
		final int _idLength = $unpackUint32();
		for (int i = 0; i < _idLength; i++) id.add($unpackUint8());
		notes = <String>[];
		final int _notesLength = $unpackUint32();
		for (int i = 0; i < _notesLength; i++) notes.add($unpackString());
		version = HalfLifeVersion.values[$unpackUint8()];
		entity = $unpackMessage(InfoEntity.$empty());
	}

	@override
	String toString() {
		return 'SendInfoMessage\x1b[0m(id: ${PackMe.dye(id)}, notes: ${PackMe.dye(notes)}, version: ${PackMe.dye(version)}, entity: ${PackMe.dye(entity)})';
	}
}

class GetDataRequest extends PackMeMessage {
	GetDataRequest({
		required this.id,
		this.limit,
	});
	GetDataRequest.$empty();

	late List<int> id;
	int? limit;

	GetDataResponse $response({
		required List<GetDataResponseItem> items,
	}) {
		final GetDataResponse message = GetDataResponse(items: items);
		message.$request = this;
		return message;
	}

	@override
	int $estimate() {
		$reset();
		int _bytes = 9;
		_bytes += 4 + id.length * 1;
		$setFlag(limit != null);
		if (limit != null) _bytes += 2;
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(845589919);
		for (int i = 0; i < 1; i++) $packUint8($flags[i]);
		$packUint32(id.length);
		for (int i = 0; i < id.length; i++) $packUint8(id[i]);
		if (limit != null) $packUint16(limit!);
	}

	@override
	void $unpack() {
		$initUnpack();
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		id = <int>[];
		final int _idLength = $unpackUint32();
		for (int i = 0; i < _idLength; i++) id.add($unpackUint8());
		if ($getFlag()) limit = $unpackUint16();
	}

	@override
	String toString() {
		return 'GetDataRequest\x1b[0m(id: ${PackMe.dye(id)}, limit: ${PackMe.dye(limit)})';
	}
}

class GetDataResponse extends PackMeMessage {
	GetDataResponse({
		required this.items,
	});
	GetDataResponse.$empty();

	late List<GetDataResponseItem> items;


	@override
	int $estimate() {
		$reset();
		int _bytes = 8;
		_bytes += 4 + items.fold(0, (int a, GetDataResponseItem b) => a + b.$estimate());
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(160528308);
		$packUint32(items.length);
		for (int i = 0; i < items.length; i++) $packMessage(items[i]);
	}

	@override
	void $unpack() {
		$initUnpack();
		items = <GetDataResponseItem>[];
		final int _itemsLength = $unpackUint32();
		for (int i = 0; i < _itemsLength; i++) items.add($unpackMessage(GetDataResponseItem.$empty()));
	}

	@override
	String toString() {
		return 'GetDataResponse\x1b[0m(items: ${PackMe.dye(items)})';
	}
}

final Map<int, PackMeMessage Function()> compilerTestMessageFactory = <int, PackMeMessage Function()>{
	511521838: () => SendInfoMessage.$empty(),
	845589919: () => GetDataRequest.$empty(),
	160528308: () => GetDataResponse.$empty(),
};