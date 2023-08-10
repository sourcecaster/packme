/// This class describes object field of type float/double.

part of packme.compiler;

class FloatField extends Field {
    FloatField(Node node, String tag, String manifest) :
            bytes = manifest == 'float' ? 4 : 8,
            super(node, tag, manifest);

    final int bytes;

    @override
    String get type => 'double';

    @override
    int get size => bytes;

    @override
    String packer([String name = '']) => bytes == 8 ? '\$packDouble($name)' : '\$packFloat($name)';

    @override
    String unpacker([String name = '']) => bytes == 8 ? r'$unpackDouble()' : r'$unpackFloat()';
}