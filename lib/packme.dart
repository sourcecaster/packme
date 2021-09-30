library packme;

import 'dart:convert';
import 'dart:typed_data';

part 'src/message.dart';

class PackMe {
	PackMe({this.onError});

	final Function(String, [StackTrace])? onError;
	final Map<int, PackMeMessage Function()> _factory = <int, PackMeMessage Function()>{};

	static String dye(dynamic x) => x is String ? '\x1b[32m$x\x1b[0m'
		: x is int || x is double || x is bool ? '\x1b[34m$x\x1b[0m'
		: '\x1b[35m$x\x1b[0m';

	void register(Map<int, PackMeMessage Function()> messageFactory) {
		_factory.addAll(messageFactory);
	}

	Uint8List? pack(PackMeMessage message) {
		try {
			message.$pack();
			return message._data!;
		}
		catch (err, stack) {
			onError?.call('Packing message failed: $err', stack);
			return null;
		}
	}

	PackMeMessage? unpack(Uint8List data) {
		try {
			if (data.length < 4) return null;
			final int id = data.buffer.asByteData().getUint32(data.offsetInBytes, Endian.big);
			final PackMeMessage? message = _factory[id]?.call();
			message?._data = data;
			message?.$unpack();
			return message;
		}
		catch (err, stack) {
			onError?.call('Unpacking message failed: $err', stack);
			return null;
		}
	}
}