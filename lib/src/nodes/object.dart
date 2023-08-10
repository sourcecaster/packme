/// This class describes object node declared in manifest.

part of packme.compiler;

class Object extends Node {
    Object(Container container, String tag, dynamic manifest) : super(container, tag, validName(tag, firstCapital: true), manifest) {
        if (isReserved(name)) {
            throw Exception('Object node "$tag" in ${container.filename}.json is resulted with the name "$name", which is reserved by Dart language.');
        }
        for (final MapEntry<String, dynamic> entry in manifest.entries) {
            final Field field = Field.fromEntry(this, entry);
            if (fields.where((Field f) => f.name == field.name).isNotEmpty) {
                throw Exception('Object declaration "$tag" in ${container.filename}.json field "${field.tag}" is parsed into a field with duplicating name "${field.name}".');
            }
            if (field is ReferenceField && field.filename != container.filename) _include(field.filename, field.referenceTag);
            fields.add(field);
        }
        _flagBytes = (fields.where((Field f) => f.optional).length / 8).ceil();
        _minBufferSize = fields.where((Field f) => f.static).fold(_flagBytes, (int a, Field b) => a + b.size);
    }

    final List<Field> fields = <Field>[];
    int _minBufferSize = 0;
    late final int _flagBytes;

    @override
    List<String> output() {
        return <String>[
            '',
            'class $name extends PackMeMessage {',

            if (fields.isNotEmpty) ...<String>[
                '$name({',
                ...fields.map((Field field) => field.initializer),
                '});'
            ]
            else '$name();',

            '$name.\$empty();\n',
            ...fields.map((Field field) => field.declaration),
            '',
            '@override',
            r'int $estimate() {',
                r'$reset();',
                if (fields.where((Field f) => !f.static).isNotEmpty) ...<String>[
                    'int _bytes = $_minBufferSize;',
                    ...fields.fold(<String>[], (Iterable<String> a, Field b) => a.toList() + b.estimate),
                    'return _bytes;',
                ]
                else 'return $_minBufferSize;',
            '}',
            '',
            '@override',
            r'void $pack() {',
                if (_flagBytes > 0) 'for (int i = 0; i < $_flagBytes; i++) \$packUint8(\$flags[i]);',
                ...fields.fold(<String>[], (Iterable<String> a, Field b) => a.toList() + b.pack),
            '}',
            '',
            '@override',
            r'void $unpack() {',
                if (_flagBytes > 0) 'for (int i = 0; i < $_flagBytes; i++) \$flags.add(\$unpackUint8());',
                ...fields.fold(<String>[], (Iterable<String> a, Field b) => a.toList() + b.unpack),
            '}',
            '',
            '@override',
                r'String toString() {',
                "return '$name\\x1b[0m(${fields.map((Field field) => '${field.name}: \${PackMe.dye(${field.name})}').join(', ')})';",
            '}',
            '}',
        ];
    }
}