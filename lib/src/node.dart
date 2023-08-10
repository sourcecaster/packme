/// This class describes a single entity (node) in manifest file (whether it's
/// enum, object, message or request).

part of packme.compiler;

abstract class Node {
    Node(this.container, this.tag, this.name, this.manifest);

    /// Try to create a Node instance of corresponding type
    static Node fromEntry(Container container, MapEntry<String, dynamic> entry) {
        if (validName(entry.key) == '') throw Exception('Node "${entry.key}" in ${container.filename}.json is resulted with the name parsed into an empty string.');
        if (entry.value is Map) return Object(container, entry.key, entry.value as Map<String, dynamic>);
        if (entry.value is List) {
            final List<dynamic> value = entry.value as List<dynamic>;
            if (value.length == 1 && value[0] is Map) return Message(container, entry.key, value);
            if (value.length == 2 && value[0] is Map && value[1] is Map) return Request(container, entry.key, value);
            if (value.fold(value.isNotEmpty, (bool a, dynamic b) => a && (b is String))) return Enum(container, entry.key, value);
        }
        throw Exception('Node "${entry.key}" in ${container.filename}.json has invalid format. Use array of strings for enum declaration, object for object declaration or array of 1 or 2 objects for message or request correspondingly.');
    }

    final Container container;
    final String tag;
    final String name;
    final dynamic manifest;

    /// Adds a reference to import from another file
    void include(String filename, String name) {
        filename += '.generated.dart';
        name = validName(name, firstCapital: true);
        container.includes[filename] ??= <String>[];
        if (!container.includes[filename]!.contains(name)) {
            container.includes[filename]!.add(name);
            container.includes[filename]!.sort();
        }
    }

    /// Adds an embedded node to output its code
    void embed(Object node) {
        container.embedded.add(node);
        container.embedded.sort((Object a, Object b) => a.name.compareTo(b.name));
    }

    /// Return resulting code, must be overridden.
    List<String> output() => <String>[];
}
