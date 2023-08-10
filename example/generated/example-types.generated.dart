import 'package:packme/packme.dart';

enum UserStatus {
	active,
	suspended,
	deleted,
}

class UserProfile extends PackMeMessage {
	UserProfile({
		required this.email,
		required this.nickname,
		this.firstName,
		this.lastName,
		this.age,
		this.birthDate,
	});
	UserProfile.$empty();

	late String email;
	late String nickname;
	String? firstName;
	String? lastName;
	int? age;
	DateTime? birthDate;

	@override
	int $estimate() {
		$reset();
		int _bytes = 1;
		_bytes += $stringBytes(email);
		_bytes += $stringBytes(nickname);
		$setFlag(firstName != null);
		if (firstName != null) _bytes += $stringBytes(firstName!);
		$setFlag(lastName != null);
		if (lastName != null) _bytes += $stringBytes(lastName!);
		$setFlag(age != null);
		if (age != null) _bytes += 1;
		$setFlag(birthDate != null);
		if (birthDate != null) _bytes += 8;
		return _bytes;
	}

	@override
	void $pack() {
		for (int i = 0; i < 1; i++) $packUint8($flags[i]);
		$packString(email);
		$packString(nickname);
		if (firstName != null) $packString(firstName!);
		if (lastName != null) $packString(lastName!);
		if (age != null) $packUint8(age!);
		if (birthDate != null) $packDateTime(birthDate!);
	}

	@override
	void $unpack() {
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		email = $unpackString();
		nickname = $unpackString();
		if ($getFlag()) firstName = $unpackString();
		if ($getFlag()) lastName = $unpackString();
		if ($getFlag()) age = $unpackUint8();
		if ($getFlag()) birthDate = $unpackDateTime();
	}

	@override
	String toString() {
		return 'UserProfile\x1b[0m(email: ${PackMe.dye(email)}, nickname: ${PackMe.dye(nickname)}, firstName: ${PackMe.dye(firstName)}, lastName: ${PackMe.dye(lastName)}, age: ${PackMe.dye(age)}, birthDate: ${PackMe.dye(birthDate)})';
	}
}

class UserSession extends PackMeMessage {
	UserSession({
		required this.created,
		required this.updated,
		required this.ip,
		required this.active,
	});
	UserSession.$empty();

	late DateTime created;
	late DateTime updated;
	late String ip;
	late bool active;

	@override
	int $estimate() {
		$reset();
		int _bytes = 17;
		_bytes += $stringBytes(ip);
		return _bytes;
	}

	@override
	void $pack() {
		$packDateTime(created);
		$packDateTime(updated);
		$packString(ip);
		$packBool(active);
	}

	@override
	void $unpack() {
		created = $unpackDateTime();
		updated = $unpackDateTime();
		ip = $unpackString();
		active = $unpackBool();
	}

	@override
	String toString() {
		return 'UserSession\x1b[0m(created: ${PackMe.dye(created)}, updated: ${PackMe.dye(updated)}, ip: ${PackMe.dye(ip)}, active: ${PackMe.dye(active)})';
	}
}