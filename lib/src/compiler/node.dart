/// This class describes a single entity in manifest (whether it's enum, type or
/// message).

part of packme.compiler;

bool _isEnumDeclaration(dynamic value) => value is List && value.isNotEmpty && value[0] is String;
bool _isTypeDeclaration(dynamic value) => value is Map;
bool _isMessageDeclaration(dynamic value) => value is List && value.length == 1 && value[0] is Map;
bool _isRequestResponseDeclaration(dynamic value) => value is List && value.length == 2 && value[0] is Map && value[1] is Map;

enum NodeType {
    enumeration,
    type,
    message,
    request
}

class Node {
    Node(this.filename, this.name, this.manifest) {
        if (_isEnumDeclaration(manifest)) type = NodeType.enumeration;
        else if (_isTypeDeclaration(manifest)) type = NodeType.type;
        else if (_isMessageDeclaration(manifest)) type = NodeType.message;
        else if (_isRequestResponseDeclaration(manifest)) type = NodeType.request;
        else throw Exception('"$name" declaration in "$filename" is invalid. Use array of strings for enum declaration, object for type declaration or array (with 1 or 2 objects) for messages.');
    }

    final String filename;
    final String name;
    final dynamic manifest;
    late final NodeType type;
}
