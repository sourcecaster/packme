import 'package:packme/packme.dart';
import 'example-types.generated.dart' show UserProfile, UserSession, UserStatus;

class GetUserResponseSocial extends PackMeMessage {
	GetUserResponseSocial({
		this.facebookId,
		this.twitterId,
		this.instagramId,
	});
	GetUserResponseSocial.$empty();

	String? facebookId;
	String? twitterId;
	String? instagramId;

	@override
	int $estimate() {
		$reset();
		int _bytes = 1;
		$setFlag(facebookId != null);
		if (facebookId != null) _bytes += $stringBytes(facebookId!);
		$setFlag(twitterId != null);
		if (twitterId != null) _bytes += $stringBytes(twitterId!);
		$setFlag(instagramId != null);
		if (instagramId != null) _bytes += $stringBytes(instagramId!);
		return _bytes;
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
		if ($getFlag()) facebookId = $unpackString();
		if ($getFlag()) twitterId = $unpackString();
		if ($getFlag()) instagramId = $unpackString();
	}

	@override
	String toString() {
		return 'GetUserResponseSocial\x1b[0m(facebookId: ${PackMe.dye(facebookId)}, twitterId: ${PackMe.dye(twitterId)}, instagramId: ${PackMe.dye(instagramId)})';
	}
}

class GetUsersResponseUser extends PackMeMessage {
	GetUsersResponseUser({
		required this.id,
		required this.profile,
		required this.status,
	});
	GetUsersResponseUser.$empty();

	late List<int> id;
	late UserProfile profile;
	late UserStatus status;

	@override
	int $estimate() {
		$reset();
		int _bytes = 1;
		_bytes += 4 + id.length * 1;
		_bytes += profile.$estimate();
		return _bytes;
	}

	@override
	void $pack() {
		$packUint32(id.length);
		for (int i = 0; i < id.length; i++) $packUint8(id[i]);
		$packMessage(profile);
		$packUint8(status.index);
	}

	@override
	void $unpack() {
		id = <int>[];
		final int _idLength = $unpackUint32();
		for (int i = 0; i < _idLength; i++) id.add($unpackUint8());
		profile = $unpackMessage(UserProfile.$empty());
		status = UserStatus.values[$unpackUint8()];
	}

	@override
	String toString() {
		return 'GetUsersResponseUser\x1b[0m(id: ${PackMe.dye(id)}, profile: ${PackMe.dye(profile)}, status: ${PackMe.dye(status)})';
	}
}

class GetUsersRequest extends PackMeMessage {
	GetUsersRequest({
		this.status,
	});
	GetUsersRequest.$empty();

	UserStatus? status;

	GetUsersResponse $response({
		required List<GetUsersResponseUser> users,
	}) {
		final GetUsersResponse message = GetUsersResponse(users: users);
		message.$request = this;
		return message;
	}

	@override
	int $estimate() {
		$reset();
		int _bytes = 9;
		$setFlag(status != null);
		if (status != null) _bytes += 1;
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(103027201);
		for (int i = 0; i < 1; i++) $packUint8($flags[i]);
		if (status != null) $packUint8(status!.index);
	}

	@override
	void $unpack() {
		$initUnpack();
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		if ($getFlag()) status = UserStatus.values[$unpackUint8()];
	}

	@override
	String toString() {
		return 'GetUsersRequest\x1b[0m(status: ${PackMe.dye(status)})';
	}
}

class GetUsersResponse extends PackMeMessage {
	GetUsersResponse({
		required this.users,
	});
	GetUsersResponse.$empty();

	late List<GetUsersResponseUser> users;

	@override
	int $estimate() {
		$reset();
		int _bytes = 8;
		_bytes += 4 + users.fold(0, (int a, GetUsersResponseUser b) => a + b.$estimate());
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(1070081631);
		$packUint32(users.length);
		for (int i = 0; i < users.length; i++) $packMessage(users[i]);
	}

	@override
	void $unpack() {
		$initUnpack();
		users = <GetUsersResponseUser>[];
		final int _usersLength = $unpackUint32();
		for (int i = 0; i < _usersLength; i++) users.add($unpackMessage(GetUsersResponseUser.$empty()));
	}

	@override
	String toString() {
		return 'GetUsersResponse\x1b[0m(users: ${PackMe.dye(users)})';
	}
}

class GetUserRequest extends PackMeMessage {
	GetUserRequest({
		required this.userId,
	});
	GetUserRequest.$empty();

	late List<int> userId;

	GetUserResponse $response({
		required UserProfile profile,
		required DateTime created,
		required List<UserSession> sessions,
		GetUserResponseSocial? social,
	}) {
		final GetUserResponse message = GetUserResponse(profile: profile, created: created, sessions: sessions, social: social);
		message.$request = this;
		return message;
	}

	@override
	int $estimate() {
		$reset();
		int _bytes = 8;
		_bytes += 4 + userId.length * 1;
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(711286423);
		$packUint32(userId.length);
		for (int i = 0; i < userId.length; i++) $packUint8(userId[i]);
	}

	@override
	void $unpack() {
		$initUnpack();
		userId = <int>[];
		final int _userIdLength = $unpackUint32();
		for (int i = 0; i < _userIdLength; i++) userId.add($unpackUint8());
	}

	@override
	String toString() {
		return 'GetUserRequest\x1b[0m(userId: ${PackMe.dye(userId)})';
	}
}

class GetUserResponse extends PackMeMessage {
	GetUserResponse({
		required this.profile,
		required this.created,
		required this.sessions,
		this.social,
	});
	GetUserResponse.$empty();

	late UserProfile profile;
	late DateTime created;
	late List<UserSession> sessions;
	GetUserResponseSocial? social;

	@override
	int $estimate() {
		$reset();
		int _bytes = 17;
		_bytes += profile.$estimate();
		_bytes += 4 + sessions.fold(0, (int a, UserSession b) => a + b.$estimate());
		$setFlag(social != null);
		if (social != null) _bytes += social!.$estimate();
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(164269114);
		for (int i = 0; i < 1; i++) $packUint8($flags[i]);
		$packMessage(profile);
		$packDateTime(created);
		$packUint32(sessions.length);
		for (int i = 0; i < sessions.length; i++) $packMessage(sessions[i]);
		if (social != null) $packMessage(social!);
	}

	@override
	void $unpack() {
		$initUnpack();
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		profile = $unpackMessage(UserProfile.$empty());
		created = $unpackDateTime();
		sessions = <UserSession>[];
		final int _sessionsLength = $unpackUint32();
		for (int i = 0; i < _sessionsLength; i++) sessions.add($unpackMessage(UserSession.$empty()));
		if ($getFlag()) social = $unpackMessage(GetUserResponseSocial.$empty());
	}

	@override
	String toString() {
		return 'GetUserResponse\x1b[0m(profile: ${PackMe.dye(profile)}, created: ${PackMe.dye(created)}, sessions: ${PackMe.dye(sessions)}, social: ${PackMe.dye(social)})';
	}
}

class DeleteUserRequest extends PackMeMessage {
	DeleteUserRequest({
		required this.userId,
	});
	DeleteUserRequest.$empty();

	late List<int> userId;

	DeleteUserResponse $response({
		String? error,
	}) {
		final DeleteUserResponse message = DeleteUserResponse(error: error);
		message.$request = this;
		return message;
	}

	@override
	int $estimate() {
		$reset();
		int _bytes = 8;
		_bytes += 4 + userId.length * 1;
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(117530906);
		$packUint32(userId.length);
		for (int i = 0; i < userId.length; i++) $packUint8(userId[i]);
	}

	@override
	void $unpack() {
		$initUnpack();
		userId = <int>[];
		final int _userIdLength = $unpackUint32();
		for (int i = 0; i < _userIdLength; i++) userId.add($unpackUint8());
	}

	@override
	String toString() {
		return 'DeleteUserRequest\x1b[0m(userId: ${PackMe.dye(userId)})';
	}
}

class DeleteUserResponse extends PackMeMessage {
	DeleteUserResponse({
		this.error,
	});
	DeleteUserResponse.$empty();

	String? error;

	@override
	int $estimate() {
		$reset();
		int _bytes = 9;
		$setFlag(error != null);
		if (error != null) _bytes += $stringBytes(error!);
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(196281846);
		for (int i = 0; i < 1; i++) $packUint8($flags[i]);
		if (error != null) $packString(error!);
	}

	@override
	void $unpack() {
		$initUnpack();
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		if ($getFlag()) error = $unpackString();
	}

	@override
	String toString() {
		return 'DeleteUserResponse\x1b[0m(error: ${PackMe.dye(error)})';
	}
}

final Map<int, PackMeMessage Function()> exampleUsersMessageFactory = <int, PackMeMessage Function()>{
	103027201: () => GetUsersRequest.$empty(),
	711286423: () => GetUserRequest.$empty(),
	117530906: () => DeleteUserRequest.$empty(),
	1070081631: () => GetUsersResponse.$empty(),
	164269114: () => GetUserResponse.$empty(),
	196281846: () => DeleteUserResponse.$empty(),
};