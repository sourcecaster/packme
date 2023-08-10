/// This class describes object field of type binary.

part of packme.compiler;

class BinaryField extends Field {
    BinaryField(Node node, String tag, String manifest) :
            bytes = int.parse(manifest.substring(6)),
            super(node, tag, manifest);

    final int bytes;

    @override
    String get type => 'Uint8List';

    @override
    int get size => bytes;

    @override
    String packer([String name = '']) => '\$packBinary($name, $bytes)';

    @override
    String unpacker([String name = '']) => '\$unpackBinary($bytes)';
}