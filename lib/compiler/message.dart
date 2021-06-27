/// This class describes PackMeMessage class (like request classes, response
/// classes or nested data classes).

part of packme.compiler;

class Message {
    Message(this.name, this.manifest, {this.id, this.responseClass});

    final int? id;
    final String? responseClass;
    final String name;
    final Map<String, dynamic> manifest;

    final List<String> code = <String>[];
    final List<Message> nested = <Message>[];

    /// Generate Message class code lines.
    void parse() {
        final Map<String, MessageField> fields = <String, MessageField>{};
        /// We need to estimate class data size in order to create buffer.
        int bufferSize = 0;
        /// Only optional fields require existence flags (bits).
        int optionalCount = 0;
        for (final MapEntry<String, dynamic> entry in manifest.entries) {
            final String fieldName = validName(entry.key);
            if (fieldName.isEmpty) throw Exception('Field name declaration "${entry.key}" is invalid for "$name"');
            if (fields[fieldName] != null) throw Exception('Message field name "$fieldName" is duplicated for message "$name".');
            final bool optional = entry.key[0] == '?';
            final bool array = entry.value is List;
            if (array && entry.value.length != 1) throw Exception('Array declarations must contain one single type: "${entry.value}" is invalid for field "$fieldName" of "$name"');
            dynamic value = array ? entry.value[0] : entry.value;
            if (value is Map) {
                String postfix = validName(entry.key, firstCapital: true);
                if (array && postfix[postfix.length - 1] == 's') postfix = postfix.substring(0, postfix.length - 1);
                nested.add(value = Message('$name$postfix', value as Map<String, dynamic>));
            }
            fields[fieldName] = MessageField(fieldName, value, optional, array);
            if (optional) optionalCount++;
            if (!optional && !array && value is String && value != 'string') bufferSize += sizeOf[value]!;
        }
        /// Add required bytes to store field existence flags.
        final int flagBytes = (optionalCount / 8).ceil();
        bufferSize += flagBytes;
        /// Add 4 bytes for command ID and transaction ID
        if (id != null) bufferSize += 8;

        code.addAll(<String>[
            'class $name extends PackMeMessage {',

            ...fields.values.map((MessageField field) => field.declaration),
            '',

            if (responseClass != null) ...<String>[
                '@override',
                '$responseClass get \$response {',
                    'final $responseClass message = $responseClass();',
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
            '}',

            '}\n',
        ]);
    }

    /// Return resulting code for current Message class and all nested ones.
    List<String> output() {
        final List<String> result = <String>[];
        parse();
        for (final Message message in nested) {
            result.addAll(message.output());
        }
        result.addAll(code);
        return result;
    }
}
