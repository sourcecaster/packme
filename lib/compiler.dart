/// This file allows you to generate Dart source code files for PackMe data
/// protocol using JSON manifest files.
///
/// Usage: dart compile.dart <sourceDirectory> <destinationDirectory>
///
/// JSON Manifest file represents a set of commands, each command consists of
/// one (single message) or two (request and response) messages. In your server
/// code you mostly listen for request messages from client and reply with
/// response messages. However it totally depends on your architecture: server
/// may as well send request messages and in some cases client may process those
/// requests without reply. Though using single messages are preferred in such
/// cases.
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

part 'compiler/field.dart';
part 'compiler/message.dart';
part 'compiler/parser.dart';
part 'compiler/utils.dart';

void writeOutput(String outputFilename, String prefix) {
	final List<String> out = <String>[
		"import 'package:packme/packme.dart';\n",
		...messages.values.fold(<String>[], (Iterable<String> a, Message b) => a.toList() + b.output()),
		'final Map<int, PackMeMessage Function()> ${validName(prefix)}MessageFactory = <int, PackMeMessage Function()>{',
			...messages.entries.map((MapEntry<int, Message> entry) => '	${entry.key}: () => ${entry.value.name}(),'),
		'};'
	];
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