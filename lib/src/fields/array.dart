/// This class describes object field of array type [<type>].

part of packme.compiler;

class ArrayField extends Field {
    ArrayField(Node node, String tag, List<dynamic> manifest) :
            field = Field.fromEntry(node, MapEntry<String, dynamic>(tag, manifest.first), parentIsArray: true),
            super(node, tag, manifest);

    final Field field;

    @override
    String get type => 'List<${field.type}>';

    @override
    String estimator([String name = '']) => field.static
        ? '4 + $name.length * ${field.size}'
        : '4 + $name.fold(0, (int a, ${field.type} b) => a + ${field.estimator('b')})';

    @override
    String packer([String name = '']) {
        final String i = '_i${name.length}';
        return <String>[
            '\$packUint32($name.length);',
            'for (int $i = 0; $i < $name.length; $i++) {',
                '${field.packer('$name[$i]')}${field is! ArrayField ? ';' : ''}',
            '}'
        ].join('\n');
    }

    @override
    String unpacker([String name = '']) {
        return <String>[
            'List<${field.type}>.generate(\$unpackUint32(), (int i) {',
                'return ${field.unpacker()}${field is! ArrayField ? ';' : ''}',
            '});',
        ].join('\n');
    }

    @override
    List<String> get pack {
        return <String>[
            if (optional) 'if ($name != null) {',
            ...packer(nameEnsured).split('\n'),
            if (optional) '}',
        ];
    }

    @override
    List<String> get unpack {
        return <String>[
            if (optional) r'if ($getFlag()) {',
            ...'$name = ${unpacker(nameEnsured)}'.split('\n'),
            if (optional) '}',
        ];
    }
}