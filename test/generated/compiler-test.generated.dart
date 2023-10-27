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

	static Map<Type, int> $kinIds = <Type, int>{
		InfoEntity: 0,
		InfoSubclass: 320635948,
	};

	static InfoEntity $emptyKin(int id) {
		switch (id) {
			case 320635948: return InfoSubclass.$empty();
			default: return InfoEntity.$empty();
		}
	}

	late String string;
	late int value;
	late bool flag;
	late HalfLifeVersion version;

	@override
	int $estimate() {
		$reset();
		int _bytes = 10;
		_bytes += $stringBytes(string);
		return _bytes;
	}

	@override
	void $pack() {
		$packUint32($kinIds[runtimeType] ?? 0);
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

class InfoSubclass extends InfoEntity {
	InfoSubclass({
		required String string,
		required int value,
		required bool flag,
		required HalfLifeVersion version,
		required this.weight,
		required this.comment,
	}) : super(string: string, value: value, flag: flag, version: version);
	InfoSubclass.$empty() : super.$empty();

	late double weight;
	late String comment;

	@override
	int $estimate() {
		int _bytes = super.$estimate();
		_bytes += 12;
		_bytes += $stringBytes(comment);
		return _bytes;
	}

	@override
	void $pack() {
		super.$pack();
		$packDouble(weight);
		$packString(comment);
	}

	@override
	void $unpack() {
		super.$unpack();
		weight = $unpackDouble();
		comment = $unpackString();
	}

	@override
	String toString() {
		return 'InfoSubclass\x1b[0m(string: ${PackMe.dye(string)}, value: ${PackMe.dye(value)}, flag: ${PackMe.dye(flag)}, version: ${PackMe.dye(version)}, weight: ${PackMe.dye(weight)}, comment: ${PackMe.dye(comment)})';
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
		required this.subEntity,
	});
	SendInfoMessage.$empty();

	late List<int> id;
	late List<String> notes;
	late HalfLifeVersion version;
	late InfoEntity entity;
	late InfoSubclass subEntity;

	@override
	int $estimate() {
		$reset();
		int _bytes = 9;
		_bytes += 4 + id.length * 1;
		_bytes += 4 + notes.fold(0, (int a, String b) => a + $stringBytes(b));
		_bytes += entity.$estimate();
		_bytes += subEntity.$estimate();
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(511521838);
		$packUint32(id.length);
		for (int _i2 = 0; _i2 < id.length; _i2++) {
			$packUint8(id[_i2]);
		}
		$packUint32(notes.length);
		for (int _i5 = 0; _i5 < notes.length; _i5++) {
			$packString(notes[_i5]);
		}
		$packUint8(version.index);
		$packMessage(entity);
		$packMessage(subEntity);
	}

	@override
	void $unpack() {
		$initUnpack();
		id = List<int>.generate($unpackUint32(), (int i) {
			return $unpackUint8();
		});
		notes = List<String>.generate($unpackUint32(), (int i) {
			return $unpackString();
		});
		version = HalfLifeVersion.values[$unpackUint8()];
		entity = $unpackMessage(InfoEntity.$emptyKin($unpackUint32()));
		subEntity = $unpackMessage(InfoEntity.$emptyKin($unpackUint32())) as InfoSubclass;
	}

	@override
	String toString() {
		return 'SendInfoMessage\x1b[0m(id: ${PackMe.dye(id)}, notes: ${PackMe.dye(notes)}, version: ${PackMe.dye(version)}, entity: ${PackMe.dye(entity)}, subEntity: ${PackMe.dye(subEntity)})';
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
		for (int _i2 = 0; _i2 < id.length; _i2++) {
			$packUint8(id[_i2]);
		}
		if (limit != null) $packUint16(limit!);
	}

	@override
	void $unpack() {
		$initUnpack();
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		id = List<int>.generate($unpackUint32(), (int i) {
			return $unpackUint8();
		});
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
		for (int _i5 = 0; _i5 < items.length; _i5++) {
			$packMessage(items[_i5]);
		}
	}

	@override
	void $unpack() {
		$initUnpack();
		items = List<GetDataResponseItem>.generate($unpackUint32(), (int i) {
			return $unpackMessage(GetDataResponseItem.$empty());
		});
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