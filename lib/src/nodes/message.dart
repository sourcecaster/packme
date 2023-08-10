/// This class describes message node declared in manifest.

part of packme.compiler;

class Message extends Node {
    Message(Container container, String tag, dynamic manifest) :
            id = '${validName(tag, firstCapital: true)}Message'.hashCode,
            super(container, tag, '${validName(tag, firstCapital: true)}Message', manifest) {
        if (isReserved(name)) {
            throw Exception('Message node "$tag" in ${container.filename}.json is resulted with the name "$name", which is reserved by Dart language.');
        }
    }

    final int id;

    @override
    List<String> output() {
        return <String>[

        ];
    }
}