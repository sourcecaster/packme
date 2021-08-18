part of packme.compiler;

final Map<String, Enum> enums = <String, Enum>{};
final Map<String, Message> types = <String, Message>{};
final Map<int, Message> messages = <int, Message>{};

bool _nameDuplicated(String name, [String? filename]) {
    for (final String key in enums.keys) if (name == key) return true;
    for (final String key in types.keys) if (name == key) return true;
    for (final Message message in messages.values) {
        if (name == message.name && (filename == null || message.filename == filename)) return true;
    }
    return false;
}

void _parseEnum(Node node) {
    final String name = validName(node.name, firstCapital: true);
    if (_nameDuplicated(name)) throw Exception('Enum "$name" in "${node.filename}" duplicates the name of another enum, type or message.');
    for (final dynamic element in node.manifest) {
        if (element is! String) throw Exception('Enum "$name" declaration must contain string values only.');
    }
    enums[node.name] = Enum(node.filename, name, (node.manifest as List<dynamic>).cast<String>());
}

void _parseType(Node node) {
    final String name = validName(node.name, firstCapital: true);
    if (_nameDuplicated(name)) throw Exception('Type "$name" in "${node.filename}" duplicates the name of another type, enum or message.');
    types[node.name] = Message(node.filename, name, node.manifest as Map<String, dynamic>);
}

void _parseCommand(Node node) {
    final String name = validName(node.name, firstCapital: true);
    final String nameMessage = '${name}Message';
    final String nameRequest = '${name}Request';
    final String nameResponse = '${name}Response';
    final int hashMessage = '${node.filename}$nameMessage'.hashCode;
    final int hashRequest = '${node.filename}$nameRequest'.hashCode;
    final int hashResponse = '${node.filename}$nameResponse'.hashCode;

    if (node.type == NodeType.message) {
        if (_nameDuplicated(nameMessage, node.filename)) {
            throw Exception('Message "$nameMessage" in "${node.filename}" duplicates the name of another message, type or enum.');
        }
        if (messages[hashMessage] != null) {
            throw Exception('Message name "$nameMessage" in "${node.filename}" hash code turned out to be the same as for "${messages[hashMessage]!.name}". Please try another name.');
        }
        messages[hashMessage] = Message(node.filename, nameMessage, node.manifest[0] as Map<String, dynamic>, id: hashMessage);
    }

    if (node.type == NodeType.request) {
        if (_nameDuplicated(nameRequest, node.filename)) {
            throw Exception('Message "$nameRequest" in "${node.filename}" duplicates the name of another message, type or enum.');
        }
        if (_nameDuplicated(nameResponse, node.filename)) {
            throw Exception('Message "$nameResponse" in "${node.filename}" duplicates the name of another message, type or enum.');
        }
        if (messages[hashRequest] != null) {
            throw Exception('Message "$nameRequest" in "${node.filename}" name hash code turned out to be the same as for "${messages[hashRequest]!.name}". Please try another name.');
        }
        if (messages[hashResponse] != null) {
            throw Exception('Message "$nameResponse" in "${node.filename}" name hash code turned out to be the same as for "${messages[hashResponse]!.name}". Please try another name.');
        }
        messages[hashResponse] = Message(node.filename, nameResponse, node.manifest[1] as Map<String, dynamic>, id: hashResponse);
        messages[hashRequest] = Message(node.filename, nameRequest, node.manifest[0] as Map<String, dynamic>, id: hashRequest, responseClass: messages[hashResponse]);
    }
}

Map<String, List<String>> parse(List<Node> nodes) {
    final Map<String, List<String>> codePerFile = <String, List<String>>{};
    for (final Node node in nodes) codePerFile[node.filename] ??= <String>[];
    nodes.where((Node node) => node.type == NodeType.enumeration).forEach(_parseEnum);
    nodes.where((Node node) => node.type == NodeType.type).forEach(_parseType);
    nodes.where((Node node) => node.type == NodeType.message || node.type == NodeType.request).forEach(_parseCommand);
    for (final String filename in codePerFile.keys) {
        codePerFile[filename] = <String>[
            "import 'package:packme/packme.dart';",
            '',
            ...enums.values.where((Enum item) => item.filename == filename)
                .fold(<String>[], (Iterable<String> a, Enum b) => a.toList() + b.output()),
            ...types.values.where((Message item) => item.filename == filename)
                .fold(<String>[], (Iterable<String> a, Message b) => a.toList() + b.output()),
            ...messages.values.where((Message item) => item.filename == filename)
                .fold(<String>[], (Iterable<String> a, Message b) => a.toList() + b.output()),
            if (messages.entries.where((MapEntry<int, Message> entry) => entry.value.filename == filename).isNotEmpty) ...<String>[
                'final Map<int, PackMeMessage Function()> ${validName(filename)}MessageFactory = <int, PackMeMessage Function()>{',
                ...messages.entries.where((MapEntry<int, Message> entry) => entry.value.filename == filename)
                    .map((MapEntry<int, Message> entry) => '${entry.key}: () => ${entry.value.name}.\$empty(),'),
                '};'
            ]
        ];

        /// Add additional import lines according to messages' references data.
        final List<FieldType> references = <FieldType>[];
        for (final Message message in messages.values.where((Message item) => item.filename == filename)) {
            references.addAll(message.references.where((FieldType reference) => !references.contains(reference)));
        }
        final Map<String, List<String>> imports = <String, List<String>>{};
        for (final FieldType reference in references) {
            /// Skip if enum/type declaration is in the same file.
            if (reference.filename == filename) continue;
            imports[reference.filename] ??= <String>[];
            if (!imports[reference.filename]!.contains(reference.name)) {
                imports[reference.filename]!.add(reference.name);
            }
        }
        final List<String> keys = imports.keys.toList();

        /// Sort imports properly.
        keys.sort((String a, String b) => '$a.generated.dart'.compareTo('$b.generated.dart'));
        for (final String key in keys.reversed) {
            imports[key]!.sort();
            codePerFile[filename]!.insert(1, "import '$key.generated.dart' show ${imports[key]!.join(', ')};");
        }
    }
    return codePerFile;
}
