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

final Map<int, PackMeMessage Function()> exampleMessageFactory = <int, PackMeMessage Function()>{
	856161034: () => TestMessage.$empty(),
};