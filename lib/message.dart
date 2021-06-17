part of packme;

const Utf8Codec _utf8 = Utf8Codec();

abstract class PackMeMessage {
	int _offset = 0;
	Uint8List? _data;
	static int _globalTransactionId = 0;
	int? _transactionId;
	final List<int> $flags = <int>[];
	int _bitNumber = 0;

	int get $transactionId => _transactionId ?? -1;
	PackMeMessage? get $response => null;
	set $request(PackMeMessage request) {
		_transactionId = request._transactionId;
	}

	int $estimate();
	void $pack();
	void $unpack();

	void $initPack(int commandId) {
		_data = Uint8List($estimate());
		$packUint32(commandId);
		$packUint32(_transactionId ?? (++_globalTransactionId & 0xFFFFFFFF));
	}
	void $initUnpack() {
		$unpackUint32();
		_transactionId = $unpackUint32();
	}
	void $reset() {
		_data = null;
		_offset = 0;
		$flags.clear();
		_bitNumber = 0;
	}
	void $setFlag(bool on) {
		final int index = _bitNumber ~/ 8;
		if (index >= $flags.length) $flags.add(0);
		if (on) $flags[index] |= 1 << (_bitNumber % 8);
		_bitNumber++;
	}
	bool $getFlag() {
		final int index = _bitNumber ~/ 8;
		final bool result = ($flags[index] >> (_bitNumber % 8)) & 1 == 1;
		_bitNumber++;
		return result;
	}

	int $stringBytes(String value) {
		final Uint8List bytes = _utf8.encoder.convert(value);
		return 4 + bytes.length;
	}

	void $packMessage(PackMeMessage message) {
		message._data = _data;
		message._offset = _offset;
		message.$pack();
		_offset = message._offset;
	}
	PackMeMessage $unpackMessage(PackMeMessage message) {
		message._data = _data;
		message._offset = _offset;
		message.$unpack();
		_offset = message._offset;
		return message;
	}

	void $packBool(bool value) {
		_data!.buffer.asByteData().setUint8(_offset, value ? 1 : 0);
		_offset++;
	}
	void $packInt8(int value) {
		_data!.buffer.asByteData().setInt8(_offset, value);
		_offset++;
	}
	void $packInt16(int value) {
		_data!.buffer.asByteData().setInt16(_offset, value, Endian.big);
		_offset += 2;
	}
	void $packInt32(int value) {
		_data!.buffer.asByteData().setInt32(_offset, value, Endian.big);
		_offset += 4;
	}
	void $packInt64(int value) {
		_data!.buffer.asByteData().setInt64(_offset, value, Endian.big);
		_offset += 8;
	}
	void $packUint8(int value) {
		_data!.buffer.asByteData().setUint8(_offset, value);
		_offset++;
	}
	void $packUint16(int value) {
		_data!.buffer.asByteData().setUint16(_offset, value, Endian.big);
		_offset += 2;
	}
	void $packUint32(int value) {
		_data!.buffer.asByteData().setUint32(_offset, value, Endian.big);
		_offset += 4;
	}
	void $packUint64(int value) {
		_data!.buffer.asByteData().setUint64(_offset, value, Endian.big);
		_offset += 8;
	}
	void $packFloat(double value) {
		_data!.buffer.asByteData().setFloat32(_offset, value, Endian.big);
		_offset += 4;
	}
	void $packDouble(double value) {
		_data!.buffer.asByteData().setFloat64(_offset, value, Endian.big);
		_offset += 8;
	}
	void $packDateTime(DateTime value) {
		_data!.buffer.asByteData().setUint64(_offset, value.millisecondsSinceEpoch, Endian.big);
		_offset += 8;
	}
	void $packString(String value) {
		final Uint8List bytes = _utf8.encoder.convert(value);
		_data!.buffer.asByteData().setUint32(_offset, bytes.length, Endian.big);
		_offset += 4;
		for (int i = 0; i < bytes.length; i++) {
			_data!.buffer.asByteData().setInt8(_offset++, bytes[i]);
		}
	}

	bool $unpackBool() {
		final int value = _data!.buffer.asByteData().getUint8(_offset);
		_offset++;
		return value == 1;
	}
	int $unpackInt8() {
		final int value = _data!.buffer.asByteData().getInt8(_offset);
		_offset++;
		return value;
	}
	int $unpackInt16() {
		final int value = _data!.buffer.asByteData().getInt16(_offset, Endian.big);
		_offset += 2;
		return value;
	}
	int $unpackInt32() {
		final int value = _data!.buffer.asByteData().getInt32(_offset, Endian.big);
		_offset += 4;
		return value;
	}
	int $unpackInt64() {
		final int value = _data!.buffer.asByteData().getInt64(_offset, Endian.big);
		_offset += 8;
		return value;
	}
	int $unpackUint8() {
		final int value = _data!.buffer.asByteData().getUint8(_offset);
		_offset++;
		return value;
	}
	int $unpackUint16() {
		final int value = _data!.buffer.asByteData().getUint16(_offset, Endian.big);
		_offset += 2;
		return value;
	}
	int $unpackUint32() {
		final int value = _data!.buffer.asByteData().getUint32(_offset, Endian.big);
		_offset += 4;
		return value;
	}
	int $unpackUint64() {
		final int value = _data!.buffer.asByteData().getUint64(_offset, Endian.big);
		_offset += 8;
		return value;
	}
	double $unpackFloat() {
		final double value = _data!.buffer.asByteData().getFloat32(_offset, Endian.big);
		_offset += 4;
		return value;
	}
	double $unpackDouble() {
		final double value = _data!.buffer.asByteData().getFloat64(_offset, Endian.big);
		_offset += 8;
		return value;
	}
	DateTime $unpackDateTime() {
		final int value = _data!.buffer.asByteData().getUint64(_offset, Endian.big);
		_offset += 8;
		return DateTime.fromMillisecondsSinceEpoch(value);
	}
	String $unpackString() {
		final int length = _data!.buffer.asByteData().getUint32(_offset, Endian.big);
		_offset += 4;
		final String result = _utf8.decoder.convert(_data!.buffer.asUint8List(_offset, length));
		_offset += length;
		return result;
	}
}
