/// This class describes object field of type string.

part of packme.compiler;

class StringField extends Field {
    StringField(Node node, String tag, dynamic manifest) : super(node, tag, manifest);

    @override
    String get type => 'String';

    @override
    List<String> get estimate {
        return <String>[
            if (optional) '\$setFlag($name != null);',
            if (optional) 'if ($name != null) bytes += \$stringBytes($name);'
            else 'bytes += \$stringBytes($name);'
        ];
    }

    @override
    List<String> get pack {
        return <String>[
            '${optional ? 'if ($name != null) ' : ''}\$packString($nameEnsured);'
        ];
    }

    @override
    List<String> get unpack {
        return <String>[
            '${optional ? r'if ($getFlag()) ' : ''}$name = \$unpackString();'
        ];
    }
}