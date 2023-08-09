/// This class describes object field of type bool.

part of packme.compiler;

class BoolField extends Field {
    BoolField(Node node, String tag, dynamic manifest) : super(node, tag, manifest);

    @override
    String get type => 'bool';

    @override
    int get size => 1;

    @override
    List<String> get pack {
        return <String>[
            '${optional ? 'if ($name != null) ' : ''}\$packBool($nameEnsured);'
        ];
    }

    @override
    List<String> get unpack {
        return <String>[
            '${optional ? r'if ($getFlag()) ' : ''}$name = \$unpackBool();'
        ];
    }
}