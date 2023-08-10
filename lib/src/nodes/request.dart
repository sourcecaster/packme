/// This class describes request node declared in manifest.

part of packme.compiler;

class Request extends Node {
    Request(Container container, String tag, dynamic manifest) :
            id = '${validName(tag, firstCapital: true)}Request'.hashCode,
            responseId = '${validName(tag, firstCapital: true)}Response'.hashCode,
            responseName = '${validName(tag, firstCapital: true)}Response',
            super(container, tag, '${validName(tag, firstCapital: true)}Request', manifest) {
        if (isReserved(name)) {
            throw Exception('Request node "$tag" in ${container.filename}.json is resulted with the name "$name", which is reserved by Dart language.');
        }
        if (isReserved(responseName)) {
            throw Exception('Response node "$tag" in ${container.filename}.json is resulted with the name "$responseName", which is reserved by Dart language.');
        }
    }

    final int id;
    final int responseId;
    final String responseName;

    @override
    List<String> output() {
        return <String>[

        ];
    }
}