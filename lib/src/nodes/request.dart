/// This class describes request node declared in manifest.

part of packme.compiler;

class Request extends Node {
    Request(Container container, String tag, List<dynamic> manifest) :
            id = '${container.filename}${validName(tag, firstCapital: true)}Request'.hashCode,
            responseId = '${container.filename}${validName(tag, firstCapital: true)}Response'.hashCode,
            responseName = '${validName(tag, firstCapital: true)}Response',
            super(container, tag, '${validName(tag, firstCapital: true)}Request', manifest) {
        if (isReserved(name)) {
            throw Exception('Request node "$tag" in ${container.filename}.json is resulted with the name "$name", which is reserved by Dart language.');
        }
        if (isReserved(responseName)) {
            throw Exception('Response node "$tag" in ${container.filename}.json is resulted with the name "$responseName", which is reserved by Dart language.');
        }
        responseObject = Object(container, '${tag}_response', manifest.last as Map<String, dynamic>, id: responseId);
        requestObject = Object(container, '${tag}_request', manifest.first as Map<String, dynamic>, id: id, response: responseObject);
        if (responseObject.inheritTag.isNotEmpty || requestObject.inheritTag.isNotEmpty) {
            throw Exception('Request node "$tag" in ${container.filename}.json can not be inherited from any other node.');
        }
    }

    final int id;
    final int responseId;
    final String responseName;
    late final Object requestObject;
    late final Object responseObject;

    @override
    List<String> output() => requestObject.output() + responseObject.output();
}