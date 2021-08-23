/// This file allows you to generate Dart source code files for PackMe data
/// protocol using JSON manifest files.
///
/// Usage: dart compiler.dart <sourceDirectory> <destinationDirectory>
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

part 'src/compiler/enum.dart';
part 'src/compiler/field.dart';
part 'src/compiler/fieldtype.dart';
part 'src/compiler/message.dart';
part 'src/compiler/node.dart';
part 'src/compiler/parser.dart';
part 'src/compiler/utils.dart';

void main(List<String> args) {
	final String dirPath = Directory.current.path + (args.isEmpty ? '' : '/${args[0]}');
	final String outPath = Directory.current.path + (args.length < 2 ? '' : '/${args[1]}');
	final Directory dirDir = Directory(dirPath);
	final Directory outDir = Directory(outPath);
	final List<FileSystemEntity> files = <FileSystemEntity>[];
	final RegExp reJson = RegExp(r'\.json$');
	final RegExp reName = RegExp(r'.+[\/\\](.+?)\.json$');

	try {
		if (!dirDir.existsSync()) fatal('Path not found: $dirPath');
		if (!outDir.existsSync()) outDir.createSync(recursive: true);
		files.addAll(dirDir.listSync());
	}
	catch (err) {
		fatal('Unable to process files: $err');
	}

	final List<Node> nodes = <Node>[];
	final int count = files.where((FileSystemEntity file) => reJson.hasMatch(file.path)).length;
	print('Found $count JSON manifest files in $dirPath');
	print('Output path: $outPath');
	print('...');

	for (final FileSystemEntity file in files) {
		if (!reJson.hasMatch(file.path)) continue;
		final String filename = reName.firstMatch(file.path)!.group(1)!;
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
			for (final MapEntry<String, dynamic> entry in manifest.entries) {
				nodes.add(Node(filename, entry.key, entry.value));
			}
		}
		catch (err) {
			fatal('An error occurred while reading manifest: $err');
		}
	}
	try {
		final Map<String, List<String>> codePerFile = parse(nodes);
		for (final String filename in codePerFile.keys) {
			File('$outPath/$filename.generated.dart').writeAsStringSync(format(codePerFile[filename]!).join('\n'));
		}
	}
	catch (err) {
		fatal('An error occurred while parsing manifest: $err');
	}
	print('All files are successfully processed');
}