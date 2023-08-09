/// This class describes a container of nodes which corresponds to single manifest file.

part of packme.compiler;

class Container {
    Container(this.filename, this.nodes) :
            enums = nodes.whereType<Enum>(),
            objects = nodes.whereType<Object>(),
            messages = nodes.whereType<Message>(),
            requests = nodes.whereType<Request>();

    final String filename;
    final List<Node> nodes;
    final Iterable<Enum> enums;
    final Iterable<Object> objects;
    final Iterable<Message> messages;
    final Iterable<Request> requests;

    /// Return resulting code, must be overridden.
    List<String> output(Map<String, Container> containers) {
        return <String>[
            "import 'dart:typed_data';",
            "import 'package:packme/packme.dart';",
            ...enums.fold(<String>[], (Iterable<String> a, Enum b) => a.toList() + b.output()),
            ...objects.fold(<String>[], (Iterable<String> a, Object b) => a.toList() + b.output()),
            ...messages.fold(<String>[], (Iterable<String> a, Message b) => a.toList() + b.output()),
            ...requests.fold(<String>[], (Iterable<String> a, Request b) => a.toList() + b.output()),
            if (messages.isNotEmpty || requests.isNotEmpty) ...<String>[
                '',
                'final Map<int, PackMeMessage Function()> ${validName(filename)}MessageFactory = <int, PackMeMessage Function()>{',
                ...messages.map((Message message) => '${message.id}: () => ${message.name}.\$empty(),'),
                ...requests.map((Request request) => '${request.requestId}: () => ${request.requestName}.\$empty(),\n${request.responseId}: () => ${request.responseName}.\$empty(),'),
                '};'
            ]
        ];
    }
}
