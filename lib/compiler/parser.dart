part of packme.compiler;

final Map<int, Message> allMessages = <int, Message>{};
final Map<int, Message> messages = <int, Message>{};

void parseCommands(Map<String, dynamic> node, String prefix) {
    for (final MapEntry<String, dynamic> entry in node.entries) {
        final String commandName = validName(entry.key, firstCapital: true);
        final String commandNameMessage = '${commandName}Message';
        final String commandNameRequest = '${commandName}Request';
        final String commandNameResponse = '${commandName}Response';
        final int hashMessage = '$prefix$commandNameMessage'.hashCode;
        final int hashRequest = '$prefix$commandNameRequest'.hashCode;
        final int hashResponse = '$prefix$commandNameResponse'.hashCode;

        if (commandName.isEmpty) {
            throw Exception('Command name must be adequate :) "${entry.key}" is not.');
        }
        if (entry.value is! List
            || (entry.value.length != 1 && entry.value.length != 2)
            || entry.value[0] is! Map
            || (entry.value.length == 2 && entry.value[1] is! Map)) {
            throw Exception('Command "$commandName" declaration is invalid. Must be one or two objects (single message or request and response) in array.');
        }

        /// Single Message
        if (entry.value.length == 1) {
            if (allMessages[hashMessage] != null) {
                throw Exception('Message name "$commandNameMessage" is duplicated. Or hash code turned out to be the same as for "${allMessages[hashMessage]!.name}".');
            }
            allMessages[hashMessage] = messages[hashMessage] = Message(commandNameMessage, entry.value[0] as Map<String, dynamic>, id: hashMessage);
        }

        /// Request and Response
        else {
            if (allMessages[hashRequest] != null) {
                throw Exception('Message name "$commandNameRequest" is duplicated. Or hash code turned out to be the same as for "${allMessages[hashRequest]!.name}".');
            }
            if (allMessages[hashResponse] != null) {
                throw Exception('Message name "$commandNameResponse" is duplicated. Or hash code turned out to be the same as for "${allMessages[hashResponse]!.name}".');
            }
            allMessages[hashRequest] = messages[hashRequest] = Message(commandNameRequest, entry.value[0] as Map<String, dynamic>, id: hashRequest, responseClass: commandNameResponse);
            allMessages[hashResponse] = messages[hashResponse] = Message(commandNameResponse, entry.value[1] as Map<String, dynamic>, id: hashResponse);
        }
    }
}