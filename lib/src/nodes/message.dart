/// This class describes message node declared in manifest.

part of packme.compiler;

class Message extends Node {
    Message(String filename, String tag, dynamic manifest) :
            id = '${validName(tag, firstCapital: true)}Message'.hashCode,
            name = '${validName(tag, firstCapital: true)}Message',
            super(filename, tag, manifest) {
        if (isReserved(name)) {
            throw Exception('Message node "$tag" in file "$filename" is resulted with the name "$name", which is reserved by Dart language.');
        }
    }

    final int id;
    final String name;

    @override
    List<String> output() {
        return <String>[

        ];
    }
}