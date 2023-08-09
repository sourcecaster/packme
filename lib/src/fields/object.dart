/// This class describes object field of object type { ... }.

part of packme.compiler;

class ObjectField extends Field {
    ObjectField(Node node, String tag, dynamic manifest) : super(node, tag, manifest) {

    }

    @override
    List<String> output() {
        return <String>[];
    }

    @override
    List<String> get estimate {
        return <String>[];
    }

    @override
    List<String> get pack {
        return <String>[];
    }

    @override
    List<String> get unpack {
        return <String>[];
    }
}