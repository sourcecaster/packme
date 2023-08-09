/// This class describes a single entity (node) in manifest file (whether it's
/// enum, object, message or request).

part of packme.compiler;

abstract class Node {
    Node(this.filename, this.tag, this.manifest);

    /// Try to create a Node instance of corresponding type
    static Node fromEntry(String filename, MapEntry<String, dynamic> entry) {
        if (validName(entry.key) == '') throw Exception('Node "${entry.key}" in file "$filename" is resulted with the name parsed into an empty string.');
        if (entry.value is Map) return Object(filename, entry.key, entry.value);
        if (entry.value is List) {
            final List<dynamic> value = entry.value as List<dynamic>;
            if (value.length == 1 && value[0] is Map) return Message(filename, entry.key, entry.value);
            if (value.length == 2 && value[0] is Map && value[1] is Map) return Request(filename, entry.key, entry.value);
            if (value.fold(value.isNotEmpty, (bool a, dynamic b) => a && (b is String))) return Enum(filename, entry.key, entry.value);
        }
        throw Exception('Node "${entry.key}" in file "$filename" has invalid format. Use array of strings for enum declaration, object for object declaration or array of 1 or 2 objects for message or request correspondingly.');
    }

    final String filename;
    final String tag;
    final dynamic manifest;

    /// Return resulting code, must be overridden.
    List<String> output() => <String>[];
}
