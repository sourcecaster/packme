/// This class describes object field of type datetime.

part of packme.compiler;

class DateTimeField extends Field {
    DateTimeField(Node node, String tag, String manifest) : super(node, tag, manifest);

    @override
    String get type => 'DateTime';

    @override
    int get size => 8;

    @override
    String packer([String name = '']) => '\$packDateTime($name)';

    @override
    String unpacker([String name = '']) => r'$unpackDateTime()';
}