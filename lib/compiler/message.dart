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
        code.add('class $name extends PackMeMessage {');
        for (final MessageField field in fields.values) {
            code.add('	${field.declaration}');
        }
        if (responseClass != null) {
            code.add('	');
            code.add('	@override');
            code.add('	$responseClass get \$response {');
            code.add('		final $responseClass message = $responseClass();');
            code.add(r'		message.$request = this;');
            code.add('		return message;');
            code.add('	}');
        }
        code.add('	');
        code.add('	@override');
        code.add(r'	int $estimate() {');
        code.add(r'		$reset();');
        code.add('		int bytes = $bufferSize;');
        for (final MessageField field in fields.values) {
            if (field.optional || field.array || field.type == 'string' || field.type is Message) code.addAll(field.estimate);
        }
        code.add('		return bytes;');
        code.add('	}');
        code.add('	');
        code.add('	@override');
        code.add(r'	void $pack() {');
        if (id != null) code.add('		\$initPack($id);');
        if (flagBytes > 0) code.add('		for (int i = 0; i < $flagBytes; i++) \$packUint8(\$flags[i]);');
        for (final MessageField field in fields.values) {
            code.addAll(field.pack);
        }
        code.add('	}');
        code.add('	');
        code.add('	@override');
        code.add(r'	void $unpack() {');
        if (id != null) code.add(r'		$initUnpack();'); // command ID
        if (flagBytes > 0) code.add('		for (int i = 0; i < $flagBytes; i++) \$flags.add(\$unpackUint8());');
        for (final MessageField field in fields.values) {
            code.addAll(field.unpack);
        }
        code.add('	}');
        code.add('	');
        code.add('}');
        code.add('');
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
