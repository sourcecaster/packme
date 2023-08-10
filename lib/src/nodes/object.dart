/// This class describes object node declared in manifest.

part of packme.compiler;

class Object extends Node {
    Object(Container container, String tag, Map<String, dynamic> manifest, { this.id, this.response }) :
            super(container, tag, validName(tag, firstCapital: true), manifest) {
        if (isReserved(name)) {
            throw Exception('Object node "$tag" in ${container.filename}.json is resulted with the name "$name", which is reserved by Dart language.');
        }
        for (final MapEntry<String, dynamic> entry in manifest.entries) {
            final Field field = Field.fromEntry(this, entry);
            if (fields.where((Field f) => f.name == field.name).isNotEmpty) {
                throw Exception('Object declaration "$tag" in ${container.filename}.json field "${field.tag}" is parsed into a field with duplicating name "${field.name}".');
            }
            fields.add(field);
        }
        _flagBytes = (fields.where((Field f) => f.optional).length / 8).ceil();
    }

    final List<Field> fields = <Field>[];
    int _minBufferSize = 0;
    late final int _flagBytes;
    final int? id;
    final Object? response;

    @override
    List<String> output() {
        _minBufferSize = fields.where((Field f) => f.static).fold(_flagBytes, (int a, Field b) => a + b.size);

        /// Add 4 bytes for command ID and transaction ID if this node is used by message/request node
        if (id != null) _minBufferSize += 8;

        return <String>[
            '',
            'class $name extends PackMeMessage {',

            if (fields.isNotEmpty) ...<String>[
                '$name({',
                ...fields.map((Field f) => f.initializer),
                '});'
            ]
            else '$name();',

            '$name.\$empty();\n',
            ...fields.map((Field field) => field.declaration),

            if (response != null) ...<String>[
                '',
                if (response!.fields.isNotEmpty) ...<String>[
                    '${response!.name} \$response({',
                    ...response!.fields.map((Field f) => f.attribute),
                    '}) {'
                ]
                else '${response!.name} \$response() {',
                    'final ${response!.name} message = ${response!.name}(${response!.fields.map((Field f) => '${f.name}: ${f.name}').join(', ')});',
                    r'message.$request = this;',
                    'return message;',
                '}',
            ],

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
                if (id != null) '\$initPack($id);',
                if (_flagBytes > 0) 'for (int i = 0; i < $_flagBytes; i++) \$packUint8(\$flags[i]);',
                ...fields.fold(<String>[], (Iterable<String> a, Field b) => a.toList() + b.pack),
            '}',
            '',
            '@override',
            r'void $unpack() {',
                if (id != null) r'$initUnpack();',
                if (_flagBytes > 0) 'for (int i = 0; i < $_flagBytes; i++) \$flags.add(\$unpackUint8());',
                ...fields.fold(<String>[], (Iterable<String> a, Field b) => a.toList() + b.unpack),
            '}',
            '',
            '@override',
                r'String toString() {',
                "return '$name\\x1b[0m(${fields.map((Field f) => '${f.name}: \${PackMe.dye(${f.name})}').join(', ')})';",
            '}',
            '}',
        ];
    }
}