part of packme.compiler;

final Map<String, Message> types = <String, Message>{};
final Map<int, Message> allMessages = <int, Message>{};
final Map<int, Message> messages = <int, Message>{};

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

        /// Type declaration (aka typedef for Message).
        if (entry.value is Map) {
            if (types.values.map((Message m) => m.name).contains(name)) {
                throw Exception('Type name "$name" is duplicated.');
            }
            if (allMessages.values.map((Message m) => m.name).contains(name)) {
                throw Exception('Type name "$name" duplicates Message with the same name.');
            }
            types[entry.key] = Message(name, entry.value as Map<String, dynamic>);
        }

        /// Single Message declaration.
        else if (entry.value is List && entry.value.length == 1 && entry.value[0] is Map) {
            if (allMessages[hashMessage] != null) {
                throw Exception('Message name "$nameMessage" is duplicated. Or hash code turned out to be the same as for "${allMessages[hashMessage]!.name}".');
            }
            allMessages[hashMessage] = messages[hashMessage] = Message(nameMessage, entry.value[0] as Map<String, dynamic>, id: hashMessage);
        }

        /// Request/response Messages declaration.
        else if (entry.value is List && entry.value.length == 2 && entry.value[0] is Map && entry.value[1] is Map) {
            if (allMessages[hashRequest] != null) {
                throw Exception('Message name "$nameRequest" is duplicated. Or hash code turned out to be the same as for "${allMessages[hashRequest]!.name}".');
            }
            if (allMessages[hashResponse] != null) {
                throw Exception('Message name "$nameResponse" is duplicated. Or hash code turned out to be the same as for "${allMessages[hashResponse]!.name}".');
            }
            allMessages[hashResponse] = messages[hashResponse] = Message(nameResponse, entry.value[1] as Map<String, dynamic>, id: hashResponse);
            allMessages[hashRequest] = messages[hashRequest] = Message(nameRequest, entry.value[0] as Map<String, dynamic>, id: hashRequest, responseClass: messages[hashResponse]);
        }

        /// Any other format is invalid.
        else {
            throw Exception('"$name" declaration is invalid. Use object for type declaration or array (with 1 or 2 elements) for messages.');
        }
    }
}