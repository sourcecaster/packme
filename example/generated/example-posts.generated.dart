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
		$initPack(63570112);
	}

	@override
	void $unpack() {
		$initUnpack();
	}

	@override
	String toString() {
		return 'GetAllRequest[0m()';
	}
}

class GetAllResponsePostAuthor extends PackMeMessage {
	GetAllResponsePostAuthor({
		required this.id,
		required this.nickname,
		required this.avatar,
	});
	GetAllResponsePostAuthor._empty();

	late List<int> id;
	late String nickname;
	late String avatar;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 0;
		bytes += 4;
		bytes += 1 * id.length;
		bytes += $stringBytes(nickname);
		bytes += $stringBytes(avatar);
		return bytes;
	}

	@override
	void $pack() {
		$packUint32(id.length);
		id.forEach($packUint8);
		$packString(nickname);
		$packString(avatar);
	}

	@override
	void $unpack() {
		id = <int>[];
		final int idLength = $unpackUint32();
		for (int i = 0; i < idLength; i++) {
			id.add($unpackUint8());
		}
		nickname = $unpackString();
		avatar = $unpackString();
	}

	@override
	String toString() {
		return 'GetAllResponsePostAuthor[0m(id: ${PackMe.dye(id)}, nickname: ${PackMe.dye(nickname)}, avatar: ${PackMe.dye(avatar)})';
	}
}

class GetAllResponsePost extends PackMeMessage {
	GetAllResponsePost({
		required this.id,
		required this.author,
		required this.title,
		required this.shortContent,
		required this.posted,
	});
	GetAllResponsePost._empty();

	late List<int> id;
	late GetAllResponsePostAuthor author;
	late String title;
	late String shortContent;
	late DateTime posted;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		bytes += 4;
		bytes += 1 * id.length;
		bytes += author.$estimate();
		bytes += $stringBytes(title);
		bytes += $stringBytes(shortContent);
		return bytes;
	}

	@override
	void $pack() {
		$packUint32(id.length);
		id.forEach($packUint8);
		$packMessage(author);
		$packString(title);
		$packString(shortContent);
		$packDateTime(posted);
	}

	@override
	void $unpack() {
		id = <int>[];
		final int idLength = $unpackUint32();
		for (int i = 0; i < idLength; i++) {
			id.add($unpackUint8());
		}
		author = $unpackMessage(GetAllResponsePostAuthor._empty()) as GetAllResponsePostAuthor;
		title = $unpackString();
		shortContent = $unpackString();
		posted = $unpackDateTime();
	}

	@override
	String toString() {
		return 'GetAllResponsePost[0m(id: ${PackMe.dye(id)}, author: ${PackMe.dye(author)}, title: ${PackMe.dye(title)}, shortContent: ${PackMe.dye(shortContent)}, posted: ${PackMe.dye(posted)})';
	}
}

class GetAllResponse extends PackMeMessage {
	GetAllResponse({
		required this.posts,
	});
	GetAllResponse._empty();

	late List<GetAllResponsePost> posts;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		bytes += 4;
		for (int i = 0; i < posts.length; i++) bytes += posts[i].$estimate();
		return bytes;
	}

	@override
	void $pack() {
		$initPack(280110613);
		$packUint32(posts.length);
		posts.forEach($packMessage);
	}

	@override
	void $unpack() {
		$initUnpack();
		posts = <GetAllResponsePost>[];
		final int postsLength = $unpackUint32();
		for (int i = 0; i < postsLength; i++) {
			posts.add($unpackMessage(GetAllResponsePost._empty()) as GetAllResponsePost);
		}
	}

	@override
	String toString() {
		return 'GetAllResponse[0m(posts: ${PackMe.dye(posts)})';
	}
}

class GetRequest extends PackMeMessage {
	GetRequest({
		required this.postId,
	});
	GetRequest._empty();

	late List<int> postId;
	
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
		bytes += 1 * postId.length;
		return bytes;
	}

	@override
	void $pack() {
		$initPack(187698222);
		$packUint32(postId.length);
		postId.forEach($packUint8);
	}

	@override
	void $unpack() {
		$initUnpack();
		postId = <int>[];
		final int postIdLength = $unpackUint32();
		for (int i = 0; i < postIdLength; i++) {
			postId.add($unpackUint8());
		}
	}

	@override
	String toString() {
		return 'GetRequest[0m(postId: ${PackMe.dye(postId)})';
	}
}

class GetResponseAuthor extends PackMeMessage {
	GetResponseAuthor({
		required this.id,
		required this.nickname,
		required this.avatar,
		this.facebookId,
		this.twitterId,
		this.instagramId,
	});
	GetResponseAuthor._empty();

	late List<int> id;
	late String nickname;
	late String avatar;
	String? facebookId;
	String? twitterId;
	String? instagramId;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 1;
		bytes += 4;
		bytes += 1 * id.length;
		bytes += $stringBytes(nickname);
		bytes += $stringBytes(avatar);
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
		$packUint32(id.length);
		id.forEach($packUint8);
		$packString(nickname);
		$packString(avatar);
		if (facebookId != null) $packString(facebookId!);
		if (twitterId != null) $packString(twitterId!);
		if (instagramId != null) $packString(instagramId!);
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
		avatar = $unpackString();
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
		return 'GetResponseAuthor[0m(id: ${PackMe.dye(id)}, nickname: ${PackMe.dye(nickname)}, avatar: ${PackMe.dye(avatar)}, facebookId: ${PackMe.dye(facebookId)}, twitterId: ${PackMe.dye(twitterId)}, instagramId: ${PackMe.dye(instagramId)})';
	}
}

class GetResponseStats extends PackMeMessage {
	GetResponseStats({
		required this.likes,
		required this.dislikes,
	});
	GetResponseStats._empty();

	late int likes;
	late int dislikes;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		return bytes;
	}

	@override
	void $pack() {
		$packUint32(likes);
		$packUint32(dislikes);
	}

	@override
	void $unpack() {
		likes = $unpackUint32();
		dislikes = $unpackUint32();
	}

	@override
	String toString() {
		return 'GetResponseStats[0m(likes: ${PackMe.dye(likes)}, dislikes: ${PackMe.dye(dislikes)})';
	}
}

class GetResponseCommentAuthor extends PackMeMessage {
	GetResponseCommentAuthor({
		required this.id,
		required this.nickname,
		required this.avatar,
	});
	GetResponseCommentAuthor._empty();

	late List<int> id;
	late String nickname;
	late String avatar;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 0;
		bytes += 4;
		bytes += 1 * id.length;
		bytes += $stringBytes(nickname);
		bytes += $stringBytes(avatar);
		return bytes;
	}

	@override
	void $pack() {
		$packUint32(id.length);
		id.forEach($packUint8);
		$packString(nickname);
		$packString(avatar);
	}

	@override
	void $unpack() {
		id = <int>[];
		final int idLength = $unpackUint32();
		for (int i = 0; i < idLength; i++) {
			id.add($unpackUint8());
		}
		nickname = $unpackString();
		avatar = $unpackString();
	}

	@override
	String toString() {
		return 'GetResponseCommentAuthor[0m(id: ${PackMe.dye(id)}, nickname: ${PackMe.dye(nickname)}, avatar: ${PackMe.dye(avatar)})';
	}
}

class GetResponseComment extends PackMeMessage {
	GetResponseComment({
		required this.author,
		required this.comment,
		required this.posted,
	});
	GetResponseComment._empty();

	late GetResponseCommentAuthor author;
	late String comment;
	late DateTime posted;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		bytes += author.$estimate();
		bytes += $stringBytes(comment);
		return bytes;
	}

	@override
	void $pack() {
		$packMessage(author);
		$packString(comment);
		$packDateTime(posted);
	}

	@override
	void $unpack() {
		author = $unpackMessage(GetResponseCommentAuthor._empty()) as GetResponseCommentAuthor;
		comment = $unpackString();
		posted = $unpackDateTime();
	}

	@override
	String toString() {
		return 'GetResponseComment[0m(author: ${PackMe.dye(author)}, comment: ${PackMe.dye(comment)}, posted: ${PackMe.dye(posted)})';
	}
}

class GetResponse extends PackMeMessage {
	GetResponse({
		required this.title,
		required this.content,
		required this.posted,
		required this.author,
		required this.stats,
		required this.comments,
	});
	GetResponse._empty();

	late String title;
	late String content;
	late DateTime posted;
	late GetResponseAuthor author;
	late GetResponseStats stats;
	late List<GetResponseComment> comments;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 16;
		bytes += $stringBytes(title);
		bytes += $stringBytes(content);
		bytes += author.$estimate();
		bytes += stats.$estimate();
		bytes += 4;
		for (int i = 0; i < comments.length; i++) bytes += comments[i].$estimate();
		return bytes;
	}

	@override
	void $pack() {
		$initPack(244485545);
		$packString(title);
		$packString(content);
		$packDateTime(posted);
		$packMessage(author);
		$packMessage(stats);
		$packUint32(comments.length);
		comments.forEach($packMessage);
	}

	@override
	void $unpack() {
		$initUnpack();
		title = $unpackString();
		content = $unpackString();
		posted = $unpackDateTime();
		author = $unpackMessage(GetResponseAuthor._empty()) as GetResponseAuthor;
		stats = $unpackMessage(GetResponseStats._empty()) as GetResponseStats;
		comments = <GetResponseComment>[];
		final int commentsLength = $unpackUint32();
		for (int i = 0; i < commentsLength; i++) {
			comments.add($unpackMessage(GetResponseComment._empty()) as GetResponseComment);
		}
	}

	@override
	String toString() {
		return 'GetResponse[0m(title: ${PackMe.dye(title)}, content: ${PackMe.dye(content)}, posted: ${PackMe.dye(posted)}, author: ${PackMe.dye(author)}, stats: ${PackMe.dye(stats)}, comments: ${PackMe.dye(comments)})';
	}
}

class DeleteRequest extends PackMeMessage {
	DeleteRequest({
		required this.postId,
	});
	DeleteRequest._empty();

	late List<int> postId;
	
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
		bytes += 1 * postId.length;
		return bytes;
	}

	@override
	void $pack() {
		$initPack(486637631);
		$packUint32(postId.length);
		postId.forEach($packUint8);
	}

	@override
	void $unpack() {
		$initUnpack();
		postId = <int>[];
		final int postIdLength = $unpackUint32();
		for (int i = 0; i < postIdLength; i++) {
			postId.add($unpackUint8());
		}
	}

	@override
	String toString() {
		return 'DeleteRequest[0m(postId: ${PackMe.dye(postId)})';
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
		$initPack(788388804);
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
		return 'DeleteResponse[0m(error: ${PackMe.dye(error)})';
	}
}

final Map<int, PackMeMessage Function()> examplePostsMessageFactory = <int, PackMeMessage Function()>{
		63570112: () => GetAllRequest._empty(),
		280110613: () => GetAllResponse._empty(),
		187698222: () => GetRequest._empty(),
		244485545: () => GetResponse._empty(),
		486637631: () => DeleteRequest._empty(),
		788388804: () => DeleteResponse._empty(),
};