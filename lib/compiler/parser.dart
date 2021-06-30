part of packme.compiler;

final Map<String, Enum> enums = <String, Enum>{};
final Map<String, Message> types = <String, Message>{};
final Map<int, Message> messages = <int, Message>{};
final Map<int, Message> allMessages = <int, Message>{};

bool _isEnumDeclaration(dynamic value) => value is List && value.isNotEmpty && value[0] is String;
bool _isTypeDeclaration(dynamic value) => value is Map;
bool _isMessageDeclaration(dynamic value) => value is List && value.length == 1 && value[0] is Map;
bool _isRequestResponseDeclaration(dynamic value) => value is List && value.length == 2 && value[0] is Map && value[1] is Map;

bool _nameDuplicated(String name) {
    for (final String key in enums.keys) if (name == key) return true;
    for (final String key in types.keys) if (name == key) return true;
    for (final Message message in messages.values) if (name == message.name) return true;
    return false;
}

void _checkIfValid(Map<String, dynamic> node) {
    for (final MapEntry<String, dynamic> entry in node.entries) {
        final String name = validName(entry.key, firstCapital: true);
        if (name.isEmpty) throw Exception('Declaration name must be adequate :) "${entry.key}" is not.');
        if (!_isEnumDeclaration(entry.value)
            && !_isTypeDeclaration(entry.value)
            && !_isMessageDeclaration(entry.value)
            && !_isRequestResponseDeclaration(entry.value)) {
            throw Exception('"${entry.key}" declaration is invalid. Use array of strings for enum declaration, object for type declaration or array (with 1 or 2 objects) for messages.');
        }
    }
}

void _parseEnums(Map<String, dynamic> node, String prefix) {
    for (final MapEntry<String, dynamic> entry in node.entries) {
        final String name = validName(entry.key, firstCapital: true);
        if (_isEnumDeclaration(entry.value)) {
            if (_nameDuplicated(name)) throw Exception('Enum "$name" duplicates the name of another enum, type or message.');
            for (final dynamic element in entry.value) {
                if (element is! String) throw Exception('Enum "$name" declaration must contain string values only.');
            }
            enums[entry.key] = Enum(name, (entry.value as List<dynamic>).cast<String>());
        }
    }
}

void _parseTypes(Map<String, dynamic> node, String prefix) {
    for (final MapEntry<String, dynamic> entry in node.entries) {
        final String name = validName(entry.key, firstCapital: true);
        if (_isTypeDeclaration(entry.value)) {
            if (_nameDuplicated(name)) throw Exception('Type "$name" duplicates the name of another type, enum or message.');
            types[entry.key] = Message(name, entry.value as Map<String, dynamic>);
        }
    }
}

void _parseCommands(Map<String, dynamic> node, String prefix) {
    for (final MapEntry<String, dynamic> entry in node.entries) {
        final String name = validName(entry.key, firstCapital: true);
        final String nameMessage = '${name}Message';
        final String nameRequest = '${name}Request';
        final String nameResponse = '${name}Response';
        final int hashMessage = '$prefix$nameMessage'.hashCode;
        final int hashRequest = '$prefix$nameRequest'.hashCode;
        final int hashResponse = '$prefix$nameResponse'.hashCode;

        if (_isMessageDeclaration(entry.value)) {
            if (_nameDuplicated(nameMessage)) {
                throw Exception('Message "$nameMessage" duplicates the name of another message, type or enum.');
            }
            if (allMessages[hashMessage] != null) {
                throw Exception('Message name "$nameMessage" hash code turned out to be the same as for "${allMessages[hashMessage]!.name}". Please try another name.');
            }
            allMessages[hashMessage] = messages[hashMessage] = Message(nameMessage, entry.value[0] as Map<String, dynamic>, id: hashMessage);
        }

        else if (_isRequestResponseDeclaration(entry.value)) {
            if (_nameDuplicated(nameRequest)) {
                throw Exception('Message "$nameRequest" duplicates the name of another message, type or enum.');
            }
            if (_nameDuplicated(nameResponse)) {
                throw Exception('Message "$nameResponse" duplicates the name of another message, type or enum.');
            }
            if (allMessages[hashRequest] != null) {
                throw Exception('Message name "$nameRequest" hash code turned out to be the same as for "${allMessages[hashRequest]!.name}". Please try another name.');
            }
            if (allMessages[hashResponse] != null) {
                throw Exception('Message name "$nameResponse" hash code turned out to be the same as for "${allMessages[hashResponse]!.name}". Please try another name.');
            }
            allMessages[hashResponse] = messages[hashResponse] = Message(nameResponse, entry.value[1] as Map<String, dynamic>, id: hashResponse);
            allMessages[hashRequest] = messages[hashRequest] = Message(nameRequest, entry.value[0] as Map<String, dynamic>, id: hashRequest, responseClass: messages[hashResponse]);
        }
    }
}

void parse(Map<String, dynamic> node, String prefix) {
    enums.clear();
    types.clear();
    messages.clear();
    _checkIfValid(node);
    _parseEnums(node, prefix);
    _parseTypes(node, prefix);
    _parseCommands(node, prefix);
}
