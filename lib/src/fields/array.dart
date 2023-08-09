/// This class describes object field of array type [<type>].

part of packme.compiler;

class ArrayField extends Field {
    ArrayField(Node node, String tag, dynamic manifest) : super(node, tag, manifest) {

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