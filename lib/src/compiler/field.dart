/// This class describes an individual field in PackMeMessage class.

part of packme.compiler;

final RegExp reBinary = RegExp(r'^binary\d+$');

class MessageField {
    MessageField(this.message, this.name, dynamic fieldType, this.optional, this.array) {
        if (fieldType is String && reBinary.hasMatch(fieldType)) {
            final int length = int.tryParse(fieldType.substring(6)) ?? 0;
            if (length <= 0) throw Exception('Invalid binary data length for "$name" in "${message.filename}".');
            type = 'binary';
            binary = true;
            binaryLength = length;
        }
        else {
            type = fieldType;
            binary = false;
            binaryLength = 0;
        }
    }

    final Message message;
    final String name;
    late final dynamic type;
    final bool optional;
    final bool array;
    late final bool binary;
    late final int binaryLength;

    /// Returns field name including exclamation mark if necessary.
    String get _name => '$name${optional ? '!' : ''}';

    /// Returns required Dart Type depending on field type.
    String get _type {
        switch (type) {
            case 'bool':
                return 'bool';
            case 'int8':
            case 'uint8':
            case 'int16':
            case 'uint16':
            case 'int32':
            case 'uint32':
            case 'int64':
            case 'uint64':
                return 'int';
            case 'float':
            case 'double':
                return 'double';
            case 'datetime':
                return 'DateTime';
            case 'string':
                return 'String';
            default:
                if (binary) return 'Uint8List';
                else if (type is Enum) return (type as Enum).name;
                else if (type is Message) return (type as Message).name;
                else throw Exception('Unknown data type "$type" for "$name" in "${message.filename}".');
        }
    }

    /// Returns required pack method depending on field type.
    String _pack(String name) {
        switch (type) {
            case 'bool': return 'packBool($name)';
            case 'int8': return 'packInt8($name)';
            case 'uint8': return 'packUint8($name)';
            case 'int16': return 'packInt16($name)';
            case 'uint16': return 'packUint16($name)';
            case 'int32': return 'packInt32($name)';
            case 'uint32': return 'packUint32($name)';
            case 'int64': return 'packInt64($name)';
            case 'uint64': return 'packUint64($name)';
            case 'float': return 'packFloat($name)';
            case 'double': return 'packDouble($name)';
            case 'datetime': return 'packDateTime($name)';
            case 'string': return 'packString($name)';
            default:
                if (binary) return 'packBinary($name, $binaryLength)';
                else if (type is Enum) return 'packUint8($name.index)';
                else if (type is Message) return 'packMessage($name)';
                else throw Exception('Unknown data type "$type" for "$name" in "${message.filename}".');
        }
    }

    /// Returns required unpack method depending on field type.
    String get _unpack {
        if (binary) return '\$unpackBinary($binaryLength)';
        else if (type is Enum) return '$_type.values[\$unpackUint8()]';
        else if (type is Message) return '\$unpackMessage(${type.name}.\$empty())';
        else return '\$un${_pack('')}';
    }

    /// Returns code of class field declaration.
    String get declaration {
        if (!array) return '${optional ? '' : 'late '}$_type${optional ? '?' : ''} $name;';
        else return '${optional ? '' : 'late '}List<$_type>${optional ? '?' : ''} $name;';
    }

    /// Returns code of field declaration as method attribute.
    String get attribute {
        if (!array) return '${optional ? '' : 'required '}$_type${optional ? '?' : ''} $name,';
        else return '${optional ? '' : 'required '}List<$_type>${optional ? '?' : ''} $name,';
    }

    /// Returns code required to estimate size in bytes of this field.
    List<String> get estimate {
        return <String>[
            if (optional) '\$setFlag($name != null);',
            if (optional) 'if ($name != null) {',
                if (!array) ...<String>[
                    if (binary) 'bytes += $binaryLength;'
                    else if ((type is String || type is Enum) && type != 'string') 'bytes += ${sizeOf(type)};'
                    else if (type == 'string') 'bytes += \$stringBytes($_name);'
                    else if (type is Message) 'bytes += $_name.\$estimate();'
                    else throw Exception('Wrong type "$type" for field "$name" in "${message.filename}".')
                ]
                else ...<String>[
                    'bytes += 4;',
                    if (binary) 'bytes += $binaryLength * $_name.length;'
                    else if ((type is String || type is Enum) && type != 'string') 'bytes += ${sizeOf(type)} * $_name.length;'
                    else if (type == 'string') 'for (int i = 0; i < $_name.length; i++) bytes += \$stringBytes($_name[i]);'
                    else if (type is Message) 'for (int i = 0; i < $_name.length; i++) bytes += $_name[i].\$estimate();'
                    else throw Exception('Wrong type "$type" for field "$name" in "${message.filename}".')
                ],
            if (optional) '}',
        ];
    }

    /// Returns code required to pack this field.
    List<String> get pack {
        return <String>[
            if (!array) '${optional ? 'if ($name != null) ' : ''}\$${_pack(_name)};'
            else ...<String>[
                if (optional) 'if ($name != null) {',
                    '\$packUint32($_name.length);',
                    'for (final $_type item in $_name) \$${_pack('item')};',
                if (optional) '}',
            ]
        ];
    }

    /// Returns code required to unpack this field.
    List<String> get unpack {
        return <String>[
            if (optional) r'if ($getFlag()) {',
                if (!array) '$name = $_unpack;'
                else ...<String>[
                    '$name = <$_type>[];',
                    'final int ${name}Length = \$unpackUint32();',
                    'for (int i = 0; i < ${name}Length; i++) {',
                        '$_name.add($_unpack);',
                    '}',
                ],
            if (optional) '}',
        ];
    }
}
