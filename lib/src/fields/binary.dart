/// This class describes object field of type binary.

part of packme.compiler;

class BinaryField extends Field {
    BinaryField(Node node, String tag, dynamic manifest, { required this.bytes }) : super(node, tag, manifest);

    final int bytes;

    @override
    String get type => 'Uint8List';

    @override
    int get size => bytes;

    @override
    List<String> get pack {
        return <String>[
            '${optional ? 'if ($name != null) ' : ''}\$packBinary($nameEnsured, $bytes);'
        ];
    }

    @override
    List<String> get unpack {
        return <String>[
            '${optional ? r'if ($getFlag()) ' : ''}$name = \$unpackBinary($bytes);'
        ];
    }
}