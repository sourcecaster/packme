/// This class describes request node declared in manifest.

part of packme.compiler;

class Request extends Node {
    Request(String filename, String tag, dynamic manifest) :
            requestId = '${validName(tag, firstCapital: true)}Request'.hashCode,
            responseId = '${validName(tag, firstCapital: true)}Response'.hashCode,
            requestName = '${validName(tag, firstCapital: true)}Request',
            responseName = '${validName(tag, firstCapital: true)}Response',
            super(filename, tag, manifest) {
        if (isReserved(requestName)) {
            throw Exception('Request node "$tag" in file "$filename" is resulted with the name "$requestName", which is reserved by Dart language.');
        }
        if (isReserved(responseName)) {
            throw Exception('Response node "$tag" in file "$filename" is resulted with the name "$responseName", which is reserved by Dart language.');
        }
    }

    final int requestId;
    final int responseId;
    final String requestName;
    final String responseName;

    @override
    List<String> output() {
        return <String>[

        ];
    }
}