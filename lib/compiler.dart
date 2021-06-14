/// This file allows you to generate Dart source code files for PackMe data
/// protocol using JSON manifest files.
///
/// Usage: dart compile.dart <sourceDirectory> <destinationDirectory>
///
/// JSON Manifest file represents a set of commands, each command consists of
/// two messages: request and response. In your server code you mostly listen
/// for request messages from client and reply with response messages. However
/// it totally depends on your architecture: server may as well send request
/// messages and in some cases client may process those requests without reply.
///
/// The reason why each command is strictly divided on two messages (instead of
/// just using raw messages) is to make manifest structure as clear as possible.
/// I.e. when you look at some command you already know how it is supposed to
/// work, not just some random message which will be used by server or client in
/// unobvious ways.
///
/// Another thing worth mentioning is that it is not possible to separately
/// declare a message (like in FlatBuffers or ProtoBuffers) and then reuse it in
/// different commands. Here's why: if you look carefully in .json examples you
/// will see that the same entities (like user) in different commands have
/// different set of parameters. You don't want to encode the whole user's
/// profile when you need to send a list of friends. Or when you need to show
/// short user info on the post etc. Reusing declared messages firstly leads to
/// encoding and transferring unused data, and secondly makes it hard to
/// refactor your data protocol when different parts of your application are
/// being changed.
///
/// Nested object in command request or response will be represented with class
/// SomeCommandResponsNested. For example compiling example-posts.json will
/// result in creating class GetResponseCommentAuthor which will contain three
/// fields: List<int> id, String nickname and String avatar.
///
/// Prefix "?" in field declaration means it is optional (Null by default).

library packme.compiler;

import 'dart:convert';
import 'dart:io';

const String RED = '\x1b[31m';
const String RESET = '\x1b[0m';

void fatal(String message) {
	print('$RED$message$RESET');
	exit(-1);
}

/// How many bytes required to store.

Map<String, int> sizeOf = <String, int>{
	'bool': 1,
	'int8': 1,
	'uint8': 1,
	'int16': 2,
	'uint16': 2,
	'int32': 4,
	'uint32': 4,
	'int64': 8,
	'uint64': 8,
	'float': 4,
	'double': 8,
	'datetime': 8,
};

/// Converts lower case names with underscore to UpperCamelCase (for classes) or
/// lowerCamelCase (for class fields).

String validName(String input, {bool firstCapital = false}) {
	RegExp re = firstCapital ? RegExp(r'^[a-z]|[^a-zA-Z][a-z]') : RegExp(r'[^a-zA-Z\?][a-z]');
	String result = input.replaceAllMapped(re, (Match match) => match.group(0)!.toUpperCase());
	re = RegExp(r'[^a-zA-Z0-9]');
	result = result.replaceAll(re, '');
	return result;
}

/// This class describes an individual field in PackMeMessage class.

class MessageField {
	MessageField(this.name, this.type, this.optional, this.array);

	final String name;
	final dynamic type;
	final bool optional;
	final bool array;

	/// Returns field name including exclamation mark if necessary.
	String get _name => '$name${optional ? '!' : ''}';

	/// Returns required Dart Type depending on field type.
	String get _type {
		switch (type) {
			case 'bool':
				return 'bool';
			case 'int8':
			case 'uint8':
			case 'int16':
			case 'uint16':
			case 'int32':
			case 'uint32':
			case 'int64':
			case 'uint64':
				return 'int';
			case 'float':
			case 'double':
				return 'double';
			case 'datetime':
				return 'DateTime';
			case 'string':
				return 'String';
			default:
				if (type is Message) return (type as Message).name;
				else throw Exception('Unknown data type "$type" for "$name"');
		}
	}

	/// Returns required pack method depending on field type.
	String get _pack {
		switch (type) {
			case 'bool': return 'packBool';
			case 'int8': return 'packInt8';
			case 'uint8': return 'packUint8';
			case 'int16': return 'packInt16';
			case 'uint16': return 'packUint16';
			case 'int32': return 'packInt32';
			case 'uint32': return 'packUint32';
			case 'int64': return 'packInt64';
			case 'uint64': return 'packUint64';
			case 'float': return 'packFloat';
			case 'double': return 'packDouble';
			case 'datetime': return 'packDateTime';
			case 'string': return 'packString';
			default:
				if (type is Message) return 'packMessage';
				else throw Exception('Unknown data type "$type" for "$name"');
		}
	}

	/// Returns required unpack method depending on field type.
	String get _unpack => 'un$_pack';

	/// Returns code of class field declaration.
	String get declaration {
		if (!array) return '${optional ? '' : 'late '}$_type${optional ? '?' : ''} $name;';
		else return '${optional ? '' : 'late '}List<$_type>${optional ? '?' : ''} $name;';
	}

	/// Returns code required to estimate size in bytes of this field.
	List<String> get estimate {
		final List<String> code = <String>[];
		if (optional) code.add('		setFlag($name != null);');
		if (optional) code.add('		if ($name != null) {');
		if (!array) {
			if (type is String && type != 'string') code.add('${optional ? '	' : ''}		bytes += ${sizeOf[type]};');
			else if (type == 'string') code.add('${optional ? '	' : ''}		bytes += stringBytes($_name);');
			else if (type is Message) code.add('${optional ? '	' : ''}		bytes += $_name.estimate();');
			else throw Exception('Wrong type "$type" for field "$name"');
		}
		else {
			code.add('		${optional ? '	' : ''}bytes += 4;');
			if (type is String && type != 'string') code.add('${optional ? '	' : ''}		bytes += ${sizeOf[type]} * $_name.length;');
			else if (type == 'string') code.add('${optional ? '	' : ''}		for (int i = 0; i < $_name.length; i++) bytes += stringBytes($_name[i]);');
			else if (type is Message) code.add('${optional ? '	' : ''}		for (int i = 0; i < $_name.length; i++) bytes += $_name[i].estimate();');
			else throw Exception('Wrong type "$type" for field "$name"');
		}
		if (optional) code.add('		}');
		return code;
	}

	/// Returns code required to pack this field.
	List<String> get pack {
		final List<String> code = <String>[];
		if (!array) {
			code.add('		${optional ? 'if ($name != null) ' : ''}$_pack($_name);');
		}
		else {
			if (optional) code.add('		if ($name != null) {');
			code.add('${optional ? '	' : ''}		packUint32($_name.length);');
			code.add('${optional ? '	' : ''}		$_name.forEach($_pack);');
			if (optional) code.add('		}');
		}
		return code;
	}

	/// Returns code required to unpack this field.
	List<String> get unpack {
		final List<String> code = <String>[];
		final String ending = type is Message ? '(${type.name}()) as ${type.name}' : '()';
		if (optional) code.add('		if (getFlag()) {');
		if (!array) {
			code.add('${optional ? '	' : ''}		$name = $_unpack$ending;');
		}
		else {
			code.add('${optional ? '	' : ''}		$name = <$_type>[];');
			code.add('${optional ? '	' : ''}		final int ${name}Length = unpackUint32();');
			code.add('${optional ? '	' : ''}		for (int i = 0; i < ${name}Length; i++) {');
			code.add('${optional ? '	' : ''}			$_name.add($_unpack$ending);');
			code.add('${optional ? '	' : ''}		}');
		}
		if (optional) code.add('		}');
		return code;
	}
}

/// This class describes PackMeMessage class (like request classes, response
/// classes or nested data classes).

class Message {
	Message(this.name, this.manifest, {this.id});

	final int? id;
	final String name;
	final Map<String, dynamic> manifest;

	final List<String> code = <String>[];
	final List<Message> nested = <Message>[];

	/// Generate Message class code lines.
	void parse() {
		final Map<String, MessageField> fields = <String, MessageField>{};
		/// We need to estimate class data size in order to create buffer.
		int bufferSize = 0;
		/// Only optional fields require existence flags (bits).
		int optionalCount = 0;
		for (final MapEntry<String, dynamic> entry in manifest.entries) {
			final String fieldName = validName(entry.key);
			if (fieldName.isEmpty) throw Exception('Field name declaration "${entry.key}" is invalid for "$name"');
			if (fields[fieldName] != null) throw Exception('Message field name "$fieldName" is duplicated for message "$name".');
			final bool optional = entry.key[0] == '?';
			final bool array = entry.value is List;
			if (array && entry.value.length != 1) throw Exception('Array declarations must contain one single type: "${entry.value}" is invalid for field "$fieldName" of "$name"');
			dynamic value = array ? entry.value[0] : entry.value;
			if (value is Map) {
				String postfix = validName(entry.key, firstCapital: true);
				if (array && postfix[postfix.length - 1] == 's') postfix = postfix.substring(0, postfix.length - 1);
				nested.add(value = Message('$name$postfix', value as Map<String, dynamic>));
			}
			fields[fieldName] = MessageField(fieldName, value, optional, array);
			if (optional) optionalCount++;
			if (!optional && !array && value is String && value != 'string') bufferSize += sizeOf[value]!;
		}
		/// Add required bytes to store field existence flags.
		final int flagBytes = (optionalCount / 8).ceil();
		bufferSize += flagBytes;
		/// Add 4 bytes for command ID
		if (id != null) bufferSize += 4;
		code.add('class $name extends PackMeMessage {');
		for (final MessageField field in fields.values) {
			code.add('	${field.declaration}');
		}
		code.add('	');
		code.add('	@override');
		code.add('	int estimate() {');
		code.add('		reset();');
		code.add('		int bytes = $bufferSize;');
		for (final MessageField field in fields.values) {
			if (field.optional || field.array || field.type == 'string' || field.type is Message) code.addAll(field.estimate);
		}
		code.add('		return bytes;');
		code.add('	}');
		code.add('	');
		code.add('	@override');
		code.add('	void pack() {');
		if (id != null) {
			code.add('		data = Uint8List(estimate());');
			code.add('		packUint32($id);');
		}
		if (flagBytes > 0) code.add('		for (int i = 0; i < $flagBytes; i++) packUint8(flags[i]);');
		for (final MessageField field in fields.values) {
			code.addAll(field.pack);
		}
		code.add('	}');
		code.add('	');
		code.add('	@override');
		code.add('	void unpack() {');
		if (id != null) code.add('		unpackUint32();');
		if (flagBytes > 0) code.add('		for (int i = 0; i < $flagBytes; i++) flags.add(unpackUint8());');
		for (final MessageField field in fields.values) {
			code.addAll(field.unpack);
		}
		code.add('	}');
		code.add('	');
		code.add('}');
		code.add('');
	}

	/// Return resulting code for current Message class and all nested ones.
	List<String> output() {
		final List<String> result = <String>[];
		parse();
		for (final Message message in nested) {
			result.addAll(message.output());
		}
		result.addAll(code);
		return result;
	}
}

final Map<int, Message> allMessages = <int, Message>{};
final Map<int, Message> messages = <int, Message>{};

void parseCommands(Map<String, dynamic> node, String prefix) {
	for (final MapEntry<String, dynamic> entry in node.entries) {
		final String commandName = validName(entry.key, firstCapital: true);
		final String commandNameRequest = '${commandName}Request';
		final String commandNameResponse = '${commandName}Response';
		final int hashRequest = '$prefix$commandNameRequest'.hashCode;
		final int hashResponse = '$prefix$commandNameResponse'.hashCode;
		if (commandName.isEmpty) {
			throw Exception('Command name must be adequate :) "${entry.key}" is not.');
		}
		if (entry.value is! List || entry.value.length != 2 || entry.value[0] is! Map || entry.value[1] is! Map) {
			throw Exception('Command "$commandName" declaration is invalid. Must be two objects (request and response) in array.');
		}
		if (allMessages[hashRequest] != null) {
			throw Exception('Message name "$commandNameRequest" is duplicated. Or hash code turned out to be the same as for "${allMessages[hashRequest]!.name}".');
		}
		if (allMessages[hashResponse] != null) {
			throw Exception('Message name "$commandNameResponse" is duplicated. Or hash code turned out to be the same as for "${allMessages[hashResponse]!.name}".');
		}
		allMessages[hashRequest] = messages[hashRequest] = Message(commandNameRequest, entry.value[0] as Map<String, dynamic>, id: hashRequest);
		allMessages[hashResponse] = messages[hashResponse] = Message(commandNameResponse, entry.value[1] as Map<String, dynamic>, id: hashResponse);
	}
}

void writeOutput(String outputFilename, String prefix) {
	final List<String> out = <String>[];
	out.add("import 'dart:typed_data';");
	out.add("import 'package:serveme/serveme.dart';");
	out.add('');
	for (final Message message in messages.values) {
		out.addAll(message.output());
	}
	out.add('final Map<int, PackMeMessage Function()> ${validName(prefix)}MessageFactory = <int, PackMeMessage Function()>{');
	for (final MapEntry<int, Message> entry in messages.entries) {
		out.add('	${entry.key}: () => ${entry.value.name}(),');
	}
	out.add('};');
	File(outputFilename).writeAsStringSync(out.join('\n'));
}

void main(List<String> args) {
	final String dirPath = Directory.current.path + (args.isEmpty ? '' : '/${args[0]}');
	final String outPath = Directory.current.path + (args.length < 2 ? '' : '/${args[1]}');
	final List<FileSystemEntity> files = Directory(dirPath).listSync();
	final RegExp reJson = RegExp(r'\.json$');
	final RegExp reName = RegExp(r'.+[\/\\](.+?)\.json$');
	for (final FileSystemEntity file in files) {
		if (!reJson.hasMatch(file.path)) continue;
		final String name = reName.firstMatch(file.path)!.group(1)!;
		late String json;
		try {
			json = File(file.path).readAsStringSync();
		}
		catch (err) {
			fatal('Unable to open manifest file: $err');
		}
		const JsonDecoder decoder = JsonDecoder();
		late final Map<String, dynamic> manifest;
		try {
			manifest = decoder.convert(json) as Map<String, dynamic>;
		}
		catch (err) {
			fatal('Unable to parse JSON: $err');
		}
		try {
			messages.clear();
			parseCommands(manifest, name);
		}
		catch (err) {
			fatal('An error occurred while processing manifest: $err');
		}
		try {
			writeOutput('$outPath/$name.generated.dart', name);
		}
		catch (err) {
			fatal('An error occurred while writing output file: $err');
		}
	}
}