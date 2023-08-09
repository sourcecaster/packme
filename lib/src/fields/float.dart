/// This class describes object field of type float/double.

part of packme.compiler;

class FloatField extends Field {
    FloatField(Node node, String tag, dynamic manifest, { required this.bytes }) : super(node, tag, manifest);

    final int bytes;

    @override
    String get type => 'double';

    @override
    int get size => bytes;

    @override
    List<String> get pack {
        return <String>[
            '${optional ? 'if ($name != null) ' : ''}\$pack${bytes == 8 ? 'Double' : 'Float'}($nameEnsured);'
        ];
    }

    @override
    List<String> get unpack {
        return <String>[
            '${optional ? r'if ($getFlag()) ' : ''}$name = \$unpack${bytes == 8 ? 'Double' : 'Float'}();'
        ];
    }
}