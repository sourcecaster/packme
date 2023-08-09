/// This class describes PackMeMessage class (like request classes, response
/// classes or nested data classes).

part of packme.compiler;

class Message extends FieldType {
    Message(String filename, String name, this.manifest, {this.id, this.responseClass}) : super(filename, name);

    final int? id;
    final Message? responseClass;
    final Map<String, dynamic> manifest;
    int bufferSize = 0;
    late final int flagBytes;

    final Map<String, MessageField> fields = <String, MessageField>{};
    final List<String> code = <String>[];
    final List<Message> nested = <Message>[];
    final List<FieldType> references = <FieldType>[];

    bool _initialized = false;

    void _refer(FieldType reference) {
        if (!references.contains(reference)) references.add(reference);
    }

    /// Parse manifest and initialize everything.
    void _init() {
        if (_initialized) return;
        for (final MapEntry<String, dynamic> entry in manifest.entries) {
            final String fieldName = validName(entry.key);
            if (fieldName.isEmpty) throw Exception('Field name declaration "${entry.key}" is invalid for "$name" in "$filename".');
            if (fields[fieldName] != null) throw Exception('Message field name "$fieldName" is duplicated for "$name" in "$filename".');
            if (reserved.contains(fieldName)) throw Exception('Message field name "$fieldName" is reserved by Dart for "$name" in "$filename".');
            final bool optional = entry.key[0] == '?';
            final bool array = entry.value is List;
            if (array && entry.value.length != 1) throw Exception('Array declarations must contain only one type: "${entry.value}" is invalid for field "$fieldName" of "$name" in "$filename".');
            dynamic value = array ? entry.value[0] : entry.value;

            /// Field is a nested Message object.
            if (value is Map) {
                String postfix = validName(entry.key, firstCapital: true);
                if (array && postfix[postfix.length - 1] == 's') postfix = postfix.substring(0, postfix.length - 1);
                nested.add(value = Message(filename, '$name$postfix', value as Map<String, dynamic>));
            }

            /// Field is an Enum or a referenced Message object.
            else if (value is String && value[0] == '@') {
                final Enum? enumeration = enums[value.substring(1)];
                final Message? message = types[value.substring(1)];
                if (enumeration != null) _refer(enumeration);
                else if (message != null) _refer(message);
                else throw Exception('"$name" field "$fieldName" in "$filename" type "$value" is not declared.');
                value = enumeration ?? message;
            }

            fields[fieldName] = MessageField(this, fieldName, value, optional, array);
            if (!optional && !array && (value is String || value is Enum) && value != 'string') {
                if (fields[fieldName]!.binary) bufferSize += fields[fieldName]!.binaryLength;
                else if (sizeOf(value) != null) bufferSize += sizeOf(value)!;
                else throw Exception('Unknown type "$value" for field "$fieldName" of "$name" in "$filename".');
            }
        }
        /// We need to estimate class data size in order to create buffer.
        /// Only optional fields require existence flags (bits).
        final int optionalCount = fields.values.where((MessageField f) => f.optional).length;
        /// Add required bytes to store field existence flags.
        flagBytes = (optionalCount / 8).ceil();
        bufferSize += flagBytes;
        /// Add 4 bytes for command ID and transaction ID
        if (id != null) bufferSize += 8;
        _initialized = true;
    }

    /// Generate Message class code lines.
    void _parse() {
        code.clear();
        code.addAll(<String>[
            'class $name extends PackMeMessage {',

            if (fields.isNotEmpty) ...<String>[
                '$name({',
                ...fields.values.map((MessageField field) => '${field.optional ? '' : 'required '}this.${field.name},'),
                '});'
            ]
            else '$name();',
            '$name.\$empty();\n',

            ...fields.values.map((MessageField field) => field.declaration),
            '',

            if (responseClass != null) ...<String>[
                if (responseClass!.fields.isNotEmpty) ...<String>[
                    '${responseClass!.name} \$response({',
                    ...responseClass!.fields.values.map((MessageField field) => field.attribute),
                    '}) {'
                ]
                else '${responseClass!.name} \$response() {',
                    'final ${responseClass!.name} message = ${responseClass!.name}(' +
                    responseClass!.fields.values.map((MessageField field) => '${field.name}: ${field.name}').join(', ') +
                    ');',
                    r'message.$request = this;',
                    'return message;',
                '}\n',
            ],

            '@override',
            r'int $estimate() {',
                r'$reset();',
                'int bytes = $bufferSize;',
                ...fields.values.fold(<String>[], (Iterable<String> a, MessageField b) {
                    if (b.optional || b.array || b.type == 'string' || b.type is Message) {
                        return a.toList() + b.estimate;
                    }
                    else return a;
                }),
                'return bytes;',
            '}\n',

            '@override',
            r'void $pack() {',
                if (id != null) '\$initPack($id);',
                if (flagBytes > 0) 'for (int i = 0; i < $flagBytes; i++) \$packUint8(\$flags[i]);',
                ...fields.values.fold(<String>[], (Iterable<String> a, MessageField b) => a.toList() + b.pack),
            '}\n',

            '@override',
            r'void $unpack() {',
                if (id != null) r'$initUnpack();', // command ID
                if (flagBytes > 0) 'for (int i = 0; i < $flagBytes; i++) \$flags.add(\$unpackUint8());',
                ...fields.values.fold(<String>[], (Iterable<String> a, MessageField b) => a.toList() + b.unpack),
            '}\n',

            '@override',
            r'String toString() {',
                "return '$name\\x1b[0m(${fields.values.map((MessageField field) => '${field.name}: \${PackMe.dye(${field.name})}').join(', ')})';",
            '}',

            '}\n',
        ]);
    }

    /// Return resulting code for current Message class and all nested ones.
    List<String> output() {
        _init();
        final List<String> result = <String>[];
        _parse();
        for (final Message message in nested) {
            result.addAll(message.output());
        }
        result.addAll(code);
        return result;
    }
}
