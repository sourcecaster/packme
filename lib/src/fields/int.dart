/// This class describes object field of type int8/uint8/int16/uint16/int32/uint32/int64/uint64.

part of packme.compiler;

class IntField extends Field {
    IntField(Node node, String tag, String manifest) :
            signed = manifest[0] != 'u',
            bytes = (int.parse(manifest.replaceAll(RegExp(r'\D'), '')) / 8).round(),
            super(node, tag, manifest);

    final bool signed;
    final int bytes;

    @override
    String get type => 'int';

    @override
    int get size => bytes;

    @override
    String packer([String name = '']) => '\$pack${signed ? 'Int' : 'Uint'}${bytes * 8}($name)';

    @override
    String unpacker([String name = '']) => '\$unpack${signed ? 'Int' : 'Uint'}${bytes * 8}()';
}