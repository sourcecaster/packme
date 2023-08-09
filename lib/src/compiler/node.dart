/// This class describes a single entity in manifest (whether it's #include,
/// enum, object, message or request/response).

part of packme.compiler;

bool _isIncludeDeclaration(String name, dynamic value) => name == '#include' && value is List && value.isNotEmpty && value[0] is String;
bool _isEnumDeclaration(dynamic value) => value is List && value.isNotEmpty && value[0] is String;
bool _isObjectDeclaration(dynamic value) => value is Map;
bool _isMessageDeclaration(dynamic value) => value is List && value.length == 1 && value[0] is Map;
bool _isRequestResponseDeclaration(dynamic value) => value is List && value.length == 2 && value[0] is Map && value[1] is Map;

enum NodeType {
    include,
    enumeration,
    object,
    message,
    request
}

class Node {
    Node(this.filename, this.name, this.manifest) {
        if (_isIncludeDeclaration(name, manifest)) type = NodeType.include;
        else if (_isEnumDeclaration(manifest)) type = NodeType.enumeration;
        else if (_isObjectDeclaration(manifest)) type = NodeType.object;
        else if (_isMessageDeclaration(manifest)) type = NodeType.message;
        else if (_isRequestResponseDeclaration(manifest)) type = NodeType.request;
        else throw Exception('"$name" declaration in "$filename" is invalid. Use array of strings for enum declaration, object for object declaration or array of 1 or 2 objects for message or request/response.');
    }

    final String filename;
    final String name;
    final dynamic manifest;
    late final NodeType type;
}
