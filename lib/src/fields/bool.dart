/// This class describes object field of type bool.

part of packme.compiler;

class BoolField extends Field {
    BoolField(Node node, String tag, String manifest) : super(node, tag, manifest);

    @override
    String get type => 'bool';

    @override
    int get size => 1;

    @override
    String packer([String name = '']) => '\$packBool($name)';

    @override
    String unpacker([String name = '']) => r'$unpackBool()';
}