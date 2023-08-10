/// This class describes a container of nodes which corresponds to single manifest file.

part of packme.compiler;

class Container {
    Container(this.filename, this.manifest, this.containers) {
        nodes.addAll(manifest.entries.map((MapEntry<String, dynamic> entry) => Node.fromEntry(this, entry)));
        enums = nodes.whereType<Enum>();
        objects = nodes.whereType<Object>();
        messages = nodes.whereType<Message>();
        requests = nodes.whereType<Request>();
    }

    final String filename;
    final Map<String, dynamic> manifest;
    final List<Node> nodes = <Node>[];
    late final Iterable<Enum> enums;
    late final Iterable<Object> objects;
    late final Iterable<Message> messages;
    late final Iterable<Request> requests;
    final Map<String, List<String>> includes = <String, List<String>>{};
    final List<Object> embedded = <Object>[];
    bool importTypedData = false;
    final Map<String, Container> containers;

    /// Return resulting code, must be overridden.
    List<String> output(Map<String, Container> containers) {
        return <String>[
            if (importTypedData) "import 'dart:typed_data';",
            "import 'package:packme/packme.dart';",
            ...(includes.keys.toList()..sort()).map((String filename) => "import '$filename' show ${includes[filename]!.join(', ')};"),
            ...enums.fold(<String>[], (Iterable<String> a, Enum b) => a.toList() + b.output()),
            ...objects.fold(<String>[], (Iterable<String> a, Object b) => a.toList() + b.output()),
            ...embedded.fold(<String>[], (Iterable<String> a, Object b) => a.toList() + b.output()),
            ...messages.fold(<String>[], (Iterable<String> a, Message b) => a.toList() + b.output()),
            ...requests.fold(<String>[], (Iterable<String> a, Request b) => a.toList() + b.output()),
            if (messages.isNotEmpty || requests.isNotEmpty) ...<String>[
                '',
                'final Map<int, PackMeMessage Function()> ${validName(filename)}MessageFactory = <int, PackMeMessage Function()>{',
                ...messages.map((Message message) => '${message.id}: () => ${message.name}.\$empty(),'),
                ...requests.map((Request request) => '${request.id}: () => ${request.name}.\$empty(),'),
                ...requests.map((Request request) => '${request.responseId}: () => ${request.responseName}.\$empty(),'),
                '};'
            ]
        ];
    }
}
