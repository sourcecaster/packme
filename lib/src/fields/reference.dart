/// This class describes object field of reference type @<name>.

part of packme.compiler;

class ReferenceField extends Field {
    ReferenceField(Node node, String tag, dynamic manifest) : super(node, tag, manifest) {

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