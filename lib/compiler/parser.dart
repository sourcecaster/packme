part of packme.compiler;

final Map<String, Enum> enums = <String, Enum>{};
final Map<String, Message> types = <String, Message>{};
final Map<int, Message> messages = <int, Message>{};
final Map<int, Message> allMessages = <int, Message>{};

bool nameDuplicated(String name) {
    for (final String key in enums.keys) if (name == key) return true;
    for (final String key in types.keys) if (name == key) return true;
    for (final Message message in messages.values) if (name == message.name) return true;
    return false;
}

void parseCommands(Map<String, dynamic> node, String prefix) {
    for (final MapEntry<String, dynamic> entry in node.entries) {
        final String name = validName(entry.key, firstCapital: true);
        final String nameMessage = '${name}Message';
        final String nameRequest = '${name}Request';
        final String nameResponse = '${name}Response';
        final int hashMessage = '$prefix$nameMessage'.hashCode;
        final int hashRequest = '$prefix$nameRequest'.hashCode;
        final int hashResponse = '$prefix$nameResponse'.hashCode;

        if (name.isEmpty) {
            throw Exception('Command name must be adequate :) "${entry.key}" is not.');
        }

        /// Enum type declaration.
        if (entry.value is List && entry.value.length != 0 && entry.value[0] is String) {
            if (nameDuplicated(name)) {
                throw Exception('Enum "$name" duplicates the name of another enum, type or message.');
            }
            for (final dynamic element in entry.value) {
                if (element is! String) throw Exception('Enum "$name" declaration must contain string values only.');
            }
            enums[entry.key] = Enum(name, (entry.value as List<dynamic>).cast<String>());
        }

        /// Type declaration (aka typedef for Message).
        else if (entry.value is Map) {
            if (nameDuplicated(name)) {
                throw Exception('Type "$name" duplicates the name of another type, enum or message.');
            }
            types[entry.key] = Message(name, entry.value as Map<String, dynamic>);
        }

        /// Single Message declaration.
        else if (entry.value is List && entry.value.length == 1 && entry.value[0] is Map) {
            if (nameDuplicated(nameMessage)) {
                throw Exception('Message "$nameMessage" duplicates the name of another message, type or enum.');
            }
            if (allMessages[hashMessage] != null) {
                throw Exception('Message name "$nameMessage" hash code turned out to be the same as for "${allMessages[hashMessage]!.name}". Please try another name.');
            }
            allMessages[hashMessage] = messages[hashMessage] = Message(nameMessage, entry.value[0] as Map<String, dynamic>, id: hashMessage);
        }

        /// Request/response Messages declaration.
        else if (entry.value is List && entry.value.length == 2 && entry.value[0] is Map && entry.value[1] is Map) {
            if (nameDuplicated(nameRequest)) {
                throw Exception('Message "$nameRequest" duplicates the name of another message, type or enum.');
            }
            if (nameDuplicated(nameResponse)) {
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

        /// Any other format is invalid.
        else {
            throw Exception('"$name" declaration is invalid. Use array of strings for enum declaration, object for type declaration or array (with 1 or 2 objects) for messages.');
        }
    }
}