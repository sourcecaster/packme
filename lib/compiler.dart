/// This file allows you to generate Dart source code files for PackMe data
/// protocol using JSON manifest files.
///
/// Usage: dart compiler.dart <srcDir> <outDir> [filenames (optionally)]
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
/// non-obvious ways.
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
/// SomeCommandResponseNested. For example compiling example-posts.json will
/// result in creating class GetResponseCommentAuthor which will contain three
/// fields: List<int> id, String nickname and String avatar.
///
/// Prefix "?" in field declaration means it is optional (Null by default).

library packme.compiler;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

part 'src/container.dart';
part 'src/field.dart';
part 'src/fields/array.dart';
part 'src/fields/bool.dart';
part 'src/fields/binary.dart';
part 'src/fields/datetime.dart';
part 'src/fields/float.dart';
part 'src/fields/int.dart';
part 'src/fields/object.dart';
part 'src/fields/reference.dart';
part 'src/fields/string.dart';
part 'src/node.dart';
part 'src/nodes/enum.dart';
part 'src/nodes/message.dart';
part 'src/nodes/object.dart';
part 'src/nodes/request.dart';
part 'src/utils.dart';

void main(List<String> args) {
	final bool isTest = (args.length < 3 ? '' : args[2]) == '--test';
	final String srcPath = Directory.current.path + (args.isEmpty ? '' : '/${args[0]}');
	final String outPath = Directory.current.path + (args.length < 2 ? '' : '/${args[1]}');
	List<String> filenames = args.sublist(min(2, args.length));

	/// Add file extension if not specified
	final RegExp extension = RegExp(r'\.json$');
	for (int i = 0; i < filenames.length; i++) {
		if (!extension.hasMatch(filenames[i])) filenames[i] += '.json';
	}

	/// Remove duplicates
	filenames = filenames.toSet().toList();

	try {
		print('${GREEN}Compiling ${filenames.isEmpty ? 'all .json files...' : '${filenames.length} files: ${filenames.join(', ')}...'}$RESET');
		print('$GREEN    Input directory: $YELLOW$srcPath$RESET');
		print('$GREEN    Output directory: $YELLOW$outPath$RESET');
		process(srcPath, outPath, filenames, isTest);
	}
	catch (err) {
		if (isTest) rethrow;
		else print('$RED$err$RESET');
		exit(-1);
	}
}

void process(String srcPath, String outPath, List<String> filenames, bool isTest) {
	final Directory srcDir = Directory(srcPath);
	final Directory outDir = Directory(outPath);
	final List<FileSystemEntity> files = <FileSystemEntity>[];
	final RegExp reJson = RegExp(r'\.json$');
	final RegExp reName = RegExp(r'.+[/\\](.+?)\.json$');
	try {
		if (!srcDir.existsSync()) throw Exception('Path not found: $srcPath');
		if (!outDir.existsSync()) outDir.createSync(recursive: true);
		files.addAll(srcDir.listSync());
	}
	catch (err) {
		throw Exception('Unable to process files: $err');
	}

	/// Filter file system entities, leave only manifest files to process
	files.removeWhere((FileSystemEntity file) {
		if (!reJson.hasMatch(file.path)) return true;
		if (filenames.isNotEmpty) {
			final String filename = reName.firstMatch(file.path)!.group(1)! + '.json';
			return !filenames.contains(filename);
		}
		else return false;
	});
	for (final FileSystemEntity file in files) {
		final String filename = reName.firstMatch(file.path)!.group(1)! + '.json';
		filenames.remove(filename);
	}
	if (files.isEmpty) throw Exception('No manifest files found');
	if (filenames.isNotEmpty) throw Exception('File not found: ${filenames.first}');

	final Map<String, Container> containers = <String, Container>{};

	for (final FileSystemEntity file in files) {
		final String filename = reName.firstMatch(file.path)!.group(1)!;

		/// Try to get file contents as potential JSON string
		String json;
		try {
			json = File(file.path).readAsStringSync();
		}
		catch (err) {
			throw Exception('Unable to open manifest file: $err');
		}

		/// Try to parse JSON
		const JsonDecoder decoder = JsonDecoder();
		late final Map<String, dynamic> manifest;
		try {
			manifest = decoder.convert(json) as Map<String, dynamic>;
		}
		catch (err) {
			throw Exception('Unable to parse $filename.json: $err');
		}

		/// Create nodes from parsed data
		final List<Node> nodes = <Node>[];
		for (final MapEntry<String, dynamic> entry in manifest.entries) {
			nodes.add(Node.fromEntry(filename, entry));
		}
		containers[filename] = Container(filename, nodes);
	}

	final Map<String, List<String>> codePerFile = <String, List<String>>{};

	/// Process nodes and get resulting code strings
	for (final Container container in containers.values) {
		codePerFile[container.filename] ??= <String>[];
		codePerFile[container.filename]!.addAll(container.output(containers));
	}

	/// Output resulting code
	for (final String filename in codePerFile.keys) {
		if (!isTest) {
			File('$outPath/$filename.generated.dart').writeAsStringSync(formatCode(codePerFile[filename]!).join('\n'));
		}
		else {
			print('$filename.generated.dart: ~${formatCode(codePerFile[filename]!).join('\n').length} bytes');
		}
	}

	print('$GREEN${files.length} file${ files.length > 1 ? 's are' : ' is'} successfully processed$RESET');
}