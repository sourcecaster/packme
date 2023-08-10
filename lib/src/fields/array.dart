/// This class describes object field of array type [<type>].

part of packme.compiler;

class ArrayField extends Field {
    ArrayField(Node node, String tag, List<dynamic> manifest) :
            field = Field.fromEntry(node, MapEntry<String, dynamic>('_$tag', manifest.first)),
            super(node, tag, manifest);

    final Field field;

    @override
    String get type => 'List<${field.type}>';

    @override
    String estimator([String name = '']) => field.static
        ? '4 + $name.length * ${field.size}'
        : '4 + $name.fold(0, (int a, ${field.type} b) => a + ${field.estimator('b')})';

    @override
    String packer([String name = '']) => '';

    @override
    String unpacker([String name = '']) => '';

    @override
    List<String> get estimate {
        return <String>[
            if (optional) '\$setFlag($name != null);',
            if (optional) 'if ($name != null) _bytes += ${estimator(nameEnsured)};'
            else '_bytes += ${estimator(name)};'
        ];
    }

    @override
    List<String> get pack {
        return <String>[
            if (optional) 'if ($name != null) {',
            '\$packUint32($nameEnsured.length);',
            'for (int i = 0; i < $nameEnsured.length; i++) ${field.packer('$nameEnsured[i]')};',
            if (optional) '}',
        ];
    }

    @override
    List<String> get unpack {
        return <String>[
            if (optional) r'if ($getFlag()) {',
            '$name = <${field.type}>[];',
            'final int _${name}Length = \$unpackUint32();',
            'for (int i = 0; i < _${name}Length; i++) $nameEnsured.add(${field.unpacker()});',
            if (optional) '}',
        ];
    }
}