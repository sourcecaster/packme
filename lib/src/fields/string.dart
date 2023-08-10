/// This class describes object field of type string.

part of packme.compiler;

class StringField extends Field {
    StringField(Node node, String tag, String manifest) : super(node, tag, manifest);

    @override
    String get type => 'String';

    @override
    String estimator([String name = '']) => '\$stringBytes($name)';

    @override
    String packer([String name = '']) => '\$packString($name)';

    @override
    String unpacker([String name = '']) => r'$unpackString()';

    @override
    List<String> get estimate {
        return <String>[
            if (optional) '\$setFlag($name != null);',
            if (optional) 'if ($name != null) _bytes += ${estimator(nameEnsured)};'
            else '_bytes += ${estimator(name)};'
        ];
    }
}