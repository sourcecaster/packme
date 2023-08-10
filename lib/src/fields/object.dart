/// This class describes object field of object type { ... }.

part of packme.compiler;

class ObjectField extends Field {
    ObjectField(Node node, String tag, Map<String, dynamic> manifest) : super(node, tag, manifest);

    @override
    String packer([String name = '']) => '';

    @override
    String unpacker([String name = '']) => '';

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