/// This class describes object node declared in manifest.

part of packme.compiler;

String _extractTag(String tag) => RegExp(r'(.+?)@.+').firstMatch(tag)?.group(1) ?? tag;

class Object extends Node {
    Object(Container container, String tag, Map<String, dynamic> manifest, { this.id, this.response }) :
            _inheritDescriptor = RegExp(r'.+?@(.+)$').firstMatch(tag)?.group(1) ?? '',
            super(container, _extractTag(tag), validName(_extractTag(tag), firstCapital: true), manifest) {
        inheritFilename = _inheritDescriptor.indexOf(':') > 0 ? _inheritDescriptor.substring(0, _inheritDescriptor.indexOf(':')) : container.filename;
        inheritTag = _inheritDescriptor.indexOf(':') > 0 ? _inheritDescriptor.substring(_inheritDescriptor.indexOf(':') + 1) : _inheritDescriptor;
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
    final String _inheritDescriptor;
    late final String inheritFilename;
    late final String inheritTag;

    Object _getInheritedRoot() {
        return inheritTag.isNotEmpty ? _getInheritedObject()._getInheritedRoot() : this;
    }

    Object _getInheritedObject() {
        if (!container.containers.containsKey(inheritFilename)) {
            throw Exception('Node "$tag" in ${container.filename}.json refers to file "$inheritFilename.json" '
                'which is not found within the current compilation process.');
        }
        final int index = container.containers[inheritFilename]!.nodes.indexWhere((Node n) => n is Object && n.tag == inheritTag);
        if (index == -1) throw Exception('Node "$tag" in ${container.filename}.json refers to node "$inheritTag" '
            'in $inheritFilename.json, but such enum/object node does not exist.');
        final Object resultObject = container.containers[inheritFilename]!.nodes[index] as Object;
        for (final Field field in fields) {
            if (resultObject.fields.indexWhere((Field inheritedField) => field.name == inheritedField.name) != -1) {
                throw Exception('Node "$tag" in ${container.filename}.json has a field "${field.name}" declaration '
                    'which is already inherited from the node "${resultObject.tag}" in ${container.filename}.json.');
            }
        }
        return resultObject;
    }

    List<Field> _getInheritedFields() {
        final List<Field> result = <Field>[];
        if (inheritTag.isNotEmpty) {
            final Object target = _getInheritedObject();
            result.addAll(target._getInheritedFields());
            result.addAll(target.fields);
        }
        return result;
    }

    Map<int, Object> _getChildObjects() {
        final Map<int, Object> result = <int, Object>{};
        for (final Container c in container.containers.values) {
            for (final Object o in c.objects) {
                if (o.inheritFilename == container.filename && o.inheritTag == tag) {
                    result[validName(o.tag, firstCapital: true).hashCode] = o;
                    result.addAll(o._getChildObjects());
                }
            }
        }
        return result;
    }

    @override
    List<String> output() {
        _minBufferSize = fields.where((Field f) => f.static).fold(_flagBytes, (int a, Field b) => a + b.size);

        /// Add 4 bytes for command ID and transaction ID if this node is used by message/request node
        if (id != null) _minBufferSize += 8;

        final Object? inheritedObject = inheritTag.isNotEmpty ? _getInheritedObject() : null;
        final List<Field> inheritedFields = _getInheritedFields();
        final Map<int, Object> childObjects = _getChildObjects();

        /// Add 4 bytes for specific inherited object class ID (to be able to unpack corresponding inherited object)
        if (inheritTag.isNotEmpty || childObjects.isNotEmpty) _minBufferSize += 4;

        return <String>[
            '',
            if (inheritTag.isEmpty) 'class $name extends PackMeMessage {'
            else 'class $name extends ${inheritedObject!.name} {',

            if (fields.isNotEmpty) ...<String>[
                '$name({',
                if (inheritTag.isNotEmpty) ...inheritedFields.map((Field f) => f.attribute),
                ...fields.map((Field f) => f.initializer),
                if (inheritTag.isEmpty) '});'
                else '}) : super(${inheritedFields.map((Field f) => '${f.name}: ${f.name}').join(', ')});'
            ]
            else '$name();',

            if (inheritTag.isEmpty) '$name.\$empty();\n'
            else '$name.\$empty() : super.\$empty();\n',

            if (inheritTag.isEmpty && childObjects.isNotEmpty) ...<String>[
                r'static Map<Type, int> $kinIds = <Type, int>{',
                    '$name: 0,',
                    ...childObjects.entries.map((MapEntry<int, Object> row) => '${row.value.name}: ${row.key},'),
                '};\n',
                'static $name \$emptyKin(int id) {',
                    'switch (id) {',
                        ...childObjects.entries.map((MapEntry<int, Object> row) => 'case ${row.key}: return ${row.value.name}.\$empty();'),
                        'default: return $name.\$empty();',
                    '}',
                '}\n'
            ],
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
                if (inheritTag.isEmpty) r'$reset();'
                else r'int _bytes = super.$estimate();',
                if (fields.where((Field f) => !f.static).isNotEmpty || inheritTag.isNotEmpty) ...<String>[
                    if (inheritTag.isEmpty) 'int _bytes = $_minBufferSize;'
                    else if (_minBufferSize > 0) '_bytes += $_minBufferSize;',
                    ...fields.fold(<String>[], (Iterable<String> a, Field b) => a.toList() + b.estimate),
                    'return _bytes;',
                ]
                else 'return $_minBufferSize;',
            '}',
            '',
            '@override',
            r'void $pack() {',
                if (id != null) '\$initPack($id);',
                if (inheritTag.isNotEmpty) r'super.$pack();'
                else if (childObjects.isNotEmpty) r'$packUint32($kinIds[runtimeType] ?? 0);',
                if (_flagBytes > 0) 'for (int i = 0; i < $_flagBytes; i++) \$packUint8(\$flags[i]);',
                ...fields.fold(<String>[], (Iterable<String> a, Field b) => a.toList() + b.pack),
            '}',
            '',
            '@override',
            r'void $unpack() {',
                if (id != null) r'$initUnpack();',
                if (inheritTag.isNotEmpty) r'super.$unpack();',
                if (_flagBytes > 0) 'for (int i = 0; i < $_flagBytes; i++) \$flags.add(\$unpackUint8());',
                ...fields.fold(<String>[], (Iterable<String> a, Field b) => a.toList() + b.unpack),
            '}',
            '',
            '@override',
                r'String toString() {',
                "return '$name\\x1b[0m(${<Field>[...inheritedFields, ...fields].map((Field f) => '${f.name}: \${PackMe.dye(${f.name})}').join(', ')})';",
            '}',
            '}',
        ];
    }
}