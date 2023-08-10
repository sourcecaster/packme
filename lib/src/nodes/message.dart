/// This class describes message node declared in manifest.

part of packme.compiler;

class Message extends Node {
    Message(Container container, String tag, List<dynamic> manifest) :
            id = '${container.filename}${validName(tag, firstCapital: true)}Message'.hashCode,
            super(container, tag, '${validName(tag, firstCapital: true)}Message', manifest) {
        if (isReserved(name)) {
            throw Exception('Message node "$tag" in ${container.filename}.json is resulted with the name "$name", which is reserved by Dart language.');
        }
        messageObject = Object(container, '${tag}_message', manifest.first as Map<String, dynamic>, id: id);
    }

    final int id;
    late final Object messageObject;

    @override
    List<String> output() => messageObject.output();
}