/// This file allows you to generate Dart source code files for PackMe data protocol using JSON manifest files.
///
/// Usage: dart compiler.dart <srcDir> <outDir> [filenames (optionally)]
///
/// JSON manifest file represents a set of nodes representing different entities declarations: enumerations, objects,
/// messages and requests. In your server code you mostly listen for requests from client and reply with responses.
/// However, it totally depends on your architecture: server may as well send messages to inform clint of some data
/// changes or send requests and expect clients to send back responses with corresponding data.
///
/// Enumeration declaration is represented with an array of strings. Object declaration is just an object. Message or
/// request declarations consist of array of 1 or 2 objects respectively. In case of request the second object
/// represents response declaration. Here's an example of JSON manifest file:
///
/// [
/// 	"some_enum": [
/// 		"one",
/// 		"two",
/// 		"three"
/// 	],
/// 	"some_object": {
/// 		"name": "string",
/// 		"volume": "double",
/// 		"type": "@some_enum"
/// 	},
/// 	"some_message": [
/// 		{
/// 			"update_timestamp": "uint64",
/// 			"update_coordinates": ["double"]
/// 		}
/// 	],
/// 	"some_request": [
/// 		{
/// 			"search_query": "string",
/// 			"type_filter": "@some_enum"
/// 		},
/// 		{
/// 			"search_results": ["@some_object"]
/// 		}
/// 	]
/// ]
///
/// Nested object in command request or response will be represented with new class named like
/// SomeCommandResponse<object_name>. For example compiling next manifest:
///
/// 	"get_posts": [
/// 		{
/// 			"from": "datetime",
/// 			"amount": "uint16"
/// 		},
/// 		{
/// 			"posts": [{
/// 				"id": "binary12",
/// 				"author": "string",
///					"created: "datetime",
///					"title": "string",
///					"contents": "string"
/// 			}],
/// 			"stats": {
/// 				"loaded": "uint16",
/// 				"remaining": "uint32",
/// 				"total": "uint32",
/// 			},
/// 			"?error": "string"
/// 		}
/// 	]
///
/// will result, for instance, in creating class GetPostsResponsePost (note that it has a singular form "Post", not
/// "Posts" - that is because "posts" is an array of nested object) which will contain four fields: Uint8List<int> id,
/// String author, DateTime created, String title and String contents. Also there will class GetPostsResponseStats
/// (plural this time, same as field name "stats", because it's just a nested object, not an array) which will contain
/// three int fields: loaded, remaining and total.
///
/// Here's the short list of supported features (see more details in README.md):
/// 	- prefix "?" in field declaration means it is optional (null by default);
/// 	- enumeration declaration: "color": ["black", "white", "yellow"];
/// 	- object declaration: "person": { "name": "string", "age": "uint8" };
/// 	- enumeration/object reference (filed of type enum/object declared earlier): "persons": ["@person"];
/// 	- referencing to entity from another file: "persons": ["@protocol_types:person"];
/// 	- object inheritance in object declaration: "animal": { "legs": "uint8" }, "cat@animal": { "fur": "bool" }.

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
	final bool isTest = args.isNotEmpty && args.first == '--test';
	if (isTest) args = args.sublist(1);
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

		/// Create container with nodes from parsed data
		containers[filename] = Container(filename, manifest, containers);
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