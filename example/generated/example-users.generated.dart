import 'package:packme/packme.dart';

class GetAllRequest extends PackMeMessage {
	GetAllRequest();
	GetAllRequest._empty();

	
	@override
	GetAllResponse get $response {
		final GetAllResponse message = GetAllResponse._empty();
		message.$request = this;
		return message;
	}

	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		return bytes;
	}

	@override
	void $pack() {
		$initPack(12982278);
	}

	@override
	void $unpack() {
		$initUnpack();
	}

	@override
	String toString() {
		return 'GetAllRequest\x1b[0m()';
	}
}

class GetAllResponseUser extends PackMeMessage {
	GetAllResponseUser({
		required this.id,
		required this.nickname,
		this.firstName,
		this.lastName,
		this.age,
	});
	GetAllResponseUser._empty();

	late List<int> id;
	late String nickname;
	String? firstName;
	String? lastName;
	int? age;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 1;
		bytes += 4;
		bytes += 1 * id.length;
		bytes += $stringBytes(nickname);
		$setFlag(firstName != null);
		if (firstName != null) {
			bytes += $stringBytes(firstName!);
		}
		$setFlag(lastName != null);
		if (lastName != null) {
			bytes += $stringBytes(lastName!);
		}
		$setFlag(age != null);
		if (age != null) {
			bytes += 1;
		}
		return bytes;
	}

	@override
	void $pack() {
		for (int i = 0; i < 1; i++) $packUint8($flags[i]);
		$packUint32(id.length);
		id.forEach($packUint8);
		$packString(nickname);
		if (firstName != null) $packString(firstName!);
		if (lastName != null) $packString(lastName!);
		if (age != null) $packUint8(age!);
	}

	@override
	void $unpack() {
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		id = <int>[];
		final int idLength = $unpackUint32();
		for (int i = 0; i < idLength; i++) {
			id.add($unpackUint8());
		}
		nickname = $unpackString();
		if ($getFlag()) {
			firstName = $unpackString();
		}
		if ($getFlag()) {
			lastName = $unpackString();
		}
		if ($getFlag()) {
			age = $unpackUint8();
		}
	}

	@override
	String toString() {
		return 'GetAllResponseUser\x1b[0m(id: ${PackMe.dye(id)}, nickname: ${PackMe.dye(nickname)}, firstName: ${PackMe.dye(firstName)}, lastName: ${PackMe.dye(lastName)}, age: ${PackMe.dye(age)})';
	}
}

class GetAllResponse extends PackMeMessage {
	GetAllResponse({
		required this.users,
	});
	GetAllResponse._empty();

	late List<GetAllResponseUser> users;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		bytes += 4;
		for (int i = 0; i < users.length; i++) bytes += users[i].$estimate();
		return bytes;
	}

	@override
	void $pack() {
		$initPack(242206268);
		$packUint32(users.length);
		users.forEach($packMessage);
	}

	@override
	void $unpack() {
		$initUnpack();
		users = <GetAllResponseUser>[];
		final int usersLength = $unpackUint32();
		for (int i = 0; i < usersLength; i++) {
			users.add($unpackMessage(GetAllResponseUser._empty()) as GetAllResponseUser);
		}
	}

	@override
	String toString() {
		return 'GetAllResponse\x1b[0m(users: ${PackMe.dye(users)})';
	}
}

class GetRequest extends PackMeMessage {
	GetRequest({
		required this.userId,
	});
	GetRequest._empty();

	late List<int> userId;
	
	@override
	GetResponse get $response {
		final GetResponse message = GetResponse._empty();
		message.$request = this;
		return message;
	}

	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		bytes += 4;
		bytes += 1 * userId.length;
		return bytes;
	}

	@override
	void $pack() {
		$initPack(781905656);
		$packUint32(userId.length);
		userId.forEach($packUint8);
	}

	@override
	void $unpack() {
		$initUnpack();
		userId = <int>[];
		final int userIdLength = $unpackUint32();
		for (int i = 0; i < userIdLength; i++) {
			userId.add($unpackUint8());
		}
	}

	@override
	String toString() {
		return 'GetRequest\x1b[0m(userId: ${PackMe.dye(userId)})';
	}
}

class GetResponseInfo extends PackMeMessage {
	GetResponseInfo({
		this.firstName,
		this.lastName,
		this.male,
		this.age,
		this.birthDate,
	});
	GetResponseInfo._empty();

	String? firstName;
	String? lastName;
	int? male;
	int? age;
	DateTime? birthDate;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 1;
		$setFlag(firstName != null);
		if (firstName != null) {
			bytes += $stringBytes(firstName!);
		}
		$setFlag(lastName != null);
		if (lastName != null) {
			bytes += $stringBytes(lastName!);
		}
		$setFlag(male != null);
		if (male != null) {
			bytes += 1;
		}
		$setFlag(age != null);
		if (age != null) {
			bytes += 1;
		}
		$setFlag(birthDate != null);
		if (birthDate != null) {
			bytes += 8;
		}
		return bytes;
	}

	@override
	void $pack() {
		for (int i = 0; i < 1; i++) $packUint8($flags[i]);
		if (firstName != null) $packString(firstName!);
		if (lastName != null) $packString(lastName!);
		if (male != null) $packUint8(male!);
		if (age != null) $packUint8(age!);
		if (birthDate != null) $packDateTime(birthDate!);
	}

	@override
	void $unpack() {
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		if ($getFlag()) {
			firstName = $unpackString();
		}
		if ($getFlag()) {
			lastName = $unpackString();
		}
		if ($getFlag()) {
			male = $unpackUint8();
		}
		if ($getFlag()) {
			age = $unpackUint8();
		}
		if ($getFlag()) {
			birthDate = $unpackDateTime();
		}
	}

	@override
	String toString() {
		return 'GetResponseInfo\x1b[0m(firstName: ${PackMe.dye(firstName)}, lastName: ${PackMe.dye(lastName)}, male: ${PackMe.dye(male)}, age: ${PackMe.dye(age)}, birthDate: ${PackMe.dye(birthDate)})';
	}
}

class GetResponseSocial extends PackMeMessage {
	GetResponseSocial({
		this.facebookId,
		this.twitterId,
		this.instagramId,
	});
	GetResponseSocial._empty();

	String? facebookId;
	String? twitterId;
	String? instagramId;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 1;
		$setFlag(facebookId != null);
		if (facebookId != null) {
			bytes += $stringBytes(facebookId!);
		}
		$setFlag(twitterId != null);
		if (twitterId != null) {
			bytes += $stringBytes(twitterId!);
		}
		$setFlag(instagramId != null);
		if (instagramId != null) {
			bytes += $stringBytes(instagramId!);
		}
		return bytes;
	}

	@override
	void $pack() {
		for (int i = 0; i < 1; i++) $packUint8($flags[i]);
		if (facebookId != null) $packString(facebookId!);
		if (twitterId != null) $packString(twitterId!);
		if (instagramId != null) $packString(instagramId!);
	}

	@override
	void $unpack() {
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		if ($getFlag()) {
			facebookId = $unpackString();
		}
		if ($getFlag()) {
			twitterId = $unpackString();
		}
		if ($getFlag()) {
			instagramId = $unpackString();
		}
	}

	@override
	String toString() {
		return 'GetResponseSocial\x1b[0m(facebookId: ${PackMe.dye(facebookId)}, twitterId: ${PackMe.dye(twitterId)}, instagramId: ${PackMe.dye(instagramId)})';
	}
}

class GetResponseStats extends PackMeMessage {
	GetResponseStats({
		required this.posts,
		required this.comments,
		required this.likes,
		required this.dislikes,
		required this.rating,
	});
	GetResponseStats._empty();

	late int posts;
	late int comments;
	late int likes;
	late int dislikes;
	late double rating;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 20;
		return bytes;
	}

	@override
	void $pack() {
		$packUint32(posts);
		$packUint32(comments);
		$packUint32(likes);
		$packUint32(dislikes);
		$packFloat(rating);
	}

	@override
	void $unpack() {
		posts = $unpackUint32();
		comments = $unpackUint32();
		likes = $unpackUint32();
		dislikes = $unpackUint32();
		rating = $unpackFloat();
	}

	@override
	String toString() {
		return 'GetResponseStats\x1b[0m(posts: ${PackMe.dye(posts)}, comments: ${PackMe.dye(comments)}, likes: ${PackMe.dye(likes)}, dislikes: ${PackMe.dye(dislikes)}, rating: ${PackMe.dye(rating)})';
	}
}

class GetResponseLastActive extends PackMeMessage {
	GetResponseLastActive({
		required this.datetime,
		required this.ip,
	});
	GetResponseLastActive._empty();

	late DateTime datetime;
	late String ip;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		bytes += $stringBytes(ip);
		return bytes;
	}

	@override
	void $pack() {
		$packDateTime(datetime);
		$packString(ip);
	}

	@override
	void $unpack() {
		datetime = $unpackDateTime();
		ip = $unpackString();
	}

	@override
	String toString() {
		return 'GetResponseLastActive\x1b[0m(datetime: ${PackMe.dye(datetime)}, ip: ${PackMe.dye(ip)})';
	}
}

class GetResponseSession extends PackMeMessage {
	GetResponseSession({
		required this.created,
		required this.ip,
		required this.active,
	});
	GetResponseSession._empty();

	late DateTime created;
	late String ip;
	late bool active;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 9;
		bytes += $stringBytes(ip);
		return bytes;
	}

	@override
	void $pack() {
		$packDateTime(created);
		$packString(ip);
		$packBool(active);
	}

	@override
	void $unpack() {
		created = $unpackDateTime();
		ip = $unpackString();
		active = $unpackBool();
	}

	@override
	String toString() {
		return 'GetResponseSession\x1b[0m(created: ${PackMe.dye(created)}, ip: ${PackMe.dye(ip)}, active: ${PackMe.dye(active)})';
	}
}

class GetResponse extends PackMeMessage {
	GetResponse({
		required this.email,
		required this.nickname,
		required this.hidden,
		required this.created,
		required this.info,
		required this.social,
		required this.stats,
		this.lastActive,
		required this.sessions,
	});
	GetResponse._empty();

	late String email;
	late String nickname;
	late bool hidden;
	late DateTime created;
	late GetResponseInfo info;
	late GetResponseSocial social;
	late GetResponseStats stats;
	GetResponseLastActive? lastActive;
	late List<GetResponseSession> sessions;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 18;
		bytes += $stringBytes(email);
		bytes += $stringBytes(nickname);
		bytes += info.$estimate();
		bytes += social.$estimate();
		bytes += stats.$estimate();
		$setFlag(lastActive != null);
		if (lastActive != null) {
			bytes += lastActive!.$estimate();
		}
		bytes += 4;
		for (int i = 0; i < sessions.length; i++) bytes += sessions[i].$estimate();
		return bytes;
	}

	@override
	void $pack() {
		$initPack(430536944);
		for (int i = 0; i < 1; i++) $packUint8($flags[i]);
		$packString(email);
		$packString(nickname);
		$packBool(hidden);
		$packDateTime(created);
		$packMessage(info);
		$packMessage(social);
		$packMessage(stats);
		if (lastActive != null) $packMessage(lastActive!);
		$packUint32(sessions.length);
		sessions.forEach($packMessage);
	}

	@override
	void $unpack() {
		$initUnpack();
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		email = $unpackString();
		nickname = $unpackString();
		hidden = $unpackBool();
		created = $unpackDateTime();
		info = $unpackMessage(GetResponseInfo._empty()) as GetResponseInfo;
		social = $unpackMessage(GetResponseSocial._empty()) as GetResponseSocial;
		stats = $unpackMessage(GetResponseStats._empty()) as GetResponseStats;
		if ($getFlag()) {
			lastActive = $unpackMessage(GetResponseLastActive._empty()) as GetResponseLastActive;
		}
		sessions = <GetResponseSession>[];
		final int sessionsLength = $unpackUint32();
		for (int i = 0; i < sessionsLength; i++) {
			sessions.add($unpackMessage(GetResponseSession._empty()) as GetResponseSession);
		}
	}

	@override
	String toString() {
		return 'GetResponse\x1b[0m(email: ${PackMe.dye(email)}, nickname: ${PackMe.dye(nickname)}, hidden: ${PackMe.dye(hidden)}, created: ${PackMe.dye(created)}, info: ${PackMe.dye(info)}, social: ${PackMe.dye(social)}, stats: ${PackMe.dye(stats)}, lastActive: ${PackMe.dye(lastActive)}, sessions: ${PackMe.dye(sessions)})';
	}
}

class DeleteRequest extends PackMeMessage {
	DeleteRequest({
		required this.userId,
	});
	DeleteRequest._empty();

	late List<int> userId;
	
	@override
	DeleteResponse get $response {
		final DeleteResponse message = DeleteResponse._empty();
		message.$request = this;
		return message;
	}

	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		bytes += 4;
		bytes += 1 * userId.length;
		return bytes;
	}

	@override
	void $pack() {
		$initPack(808423104);
		$packUint32(userId.length);
		userId.forEach($packUint8);
	}

	@override
	void $unpack() {
		$initUnpack();
		userId = <int>[];
		final int userIdLength = $unpackUint32();
		for (int i = 0; i < userIdLength; i++) {
			userId.add($unpackUint8());
		}
	}

	@override
	String toString() {
		return 'DeleteRequest\x1b[0m(userId: ${PackMe.dye(userId)})';
	}
}

class DeleteResponse extends PackMeMessage {
	DeleteResponse({
		this.error,
	});
	DeleteResponse._empty();

	String? error;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 9;
		$setFlag(error != null);
		if (error != null) {
			bytes += $stringBytes(error!);
		}
		return bytes;
	}

	@override
	void $pack() {
		$initPack(69897231);
		for (int i = 0; i < 1; i++) $packUint8($flags[i]);
		if (error != null) $packString(error!);
	}

	@override
	void $unpack() {
		$initUnpack();
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		if ($getFlag()) {
			error = $unpackString();
		}
	}

	@override
	String toString() {
		return 'DeleteResponse\x1b[0m(error: ${PackMe.dye(error)})';
	}
}

class UpdateSessionMessage extends PackMeMessage {
	UpdateSessionMessage({
		required this.userId,
		required this.sessionId,
	});
	UpdateSessionMessage._empty();

	late List<int> userId;
	late String sessionId;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		bytes += 4;
		bytes += 1 * userId.length;
		bytes += $stringBytes(sessionId);
		return bytes;
	}

	@override
	void $pack() {
		$initPack(743336169);
		$packUint32(userId.length);
		userId.forEach($packUint8);
		$packString(sessionId);
	}

	@override
	void $unpack() {
		$initUnpack();
		userId = <int>[];
		final int userIdLength = $unpackUint32();
		for (int i = 0; i < userIdLength; i++) {
			userId.add($unpackUint8());
		}
		sessionId = $unpackString();
	}

	@override
	String toString() {
		return 'UpdateSessionMessage\x1b[0m(userId: ${PackMe.dye(userId)}, sessionId: ${PackMe.dye(sessionId)})';
	}
}

final Map<int, PackMeMessage Function()> exampleUsersMessageFactory = <int, PackMeMessage Function()>{
		12982278: () => GetAllRequest._empty(),
		242206268: () => GetAllResponse._empty(),
		781905656: () => GetRequest._empty(),
		430536944: () => GetResponse._empty(),
		808423104: () => DeleteRequest._empty(),
		69897231: () => DeleteResponse._empty(),
		743336169: () => UpdateSessionMessage._empty(),
};