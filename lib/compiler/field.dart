/// This class describes an individual field in PackMeMessage class.

part of packme.compiler;

class MessageField {
    MessageField(this.name, this.type, this.optional, this.array);

    final String name;
    final dynamic type;
    final bool optional;
    final bool array;

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
                if (type is Message) return (type as Message).name;
                else throw Exception('Unknown data type "$type" for "$name"');
        }
    }

    /// Returns required pack method depending on field type.
    String get _pack {
        switch (type) {
            case 'bool': return 'packBool';
            case 'int8': return 'packInt8';
            case 'uint8': return 'packUint8';
            case 'int16': return 'packInt16';
            case 'uint16': return 'packUint16';
            case 'int32': return 'packInt32';
            case 'uint32': return 'packUint32';
            case 'int64': return 'packInt64';
            case 'uint64': return 'packUint64';
            case 'float': return 'packFloat';
            case 'double': return 'packDouble';
            case 'datetime': return 'packDateTime';
            case 'string': return 'packString';
            default:
                if (type is Message) return 'packMessage';
                else throw Exception('Unknown data type "$type" for "$name"');
        }
    }

    /// Returns required unpack method depending on field type.
    String get _unpack => '\$un$_pack';

    /// Returns code of class field declaration.
    String get declaration {
        if (!array) return '${optional ? '' : 'late '}$_type${optional ? '?' : ''} $name;';
        else return '${optional ? '' : 'late '}List<$_type>${optional ? '?' : ''} $name;';
    }

    /// Returns code required to estimate size in bytes of this field.
    List<String> get estimate {
        return <String>[
            if (optional) '\$setFlag($name != null);',
            if (optional) 'if ($name != null) {',
                if (!array) ...<String>[
                    if (type is String && type != 'string') 'bytes += ${sizeOf[type]};'
                    else if (type == 'string') 'bytes += \$stringBytes($_name);'
                    else if (type is Message) 'bytes += $_name.\$estimate();'
                    else throw Exception('Wrong type "$type" for field "$name"')
                ]
                else ...<String>[
                    'bytes += 4;',
                    if (type is String && type != 'string') 'bytes += ${sizeOf[type]} * $_name.length;'
                    else if (type == 'string') 'for (int i = 0; i < $_name.length; i++) bytes += \$stringBytes($_name[i]);'
                    else if (type is Message) 'for (int i = 0; i < $_name.length; i++) bytes += $_name[i].\$estimate();'
                    else throw Exception('Wrong type "$type" for field "$name"')
                ],
            if (optional) '}',
        ];
    }

    /// Returns code required to pack this field.
    List<String> get pack {
        return <String>[
            if (!array) '${optional ? 'if ($name != null) ' : ''}\$$_pack($_name);'
            else ...<String>[
                if (optional) 'if ($name != null) {',
                    '\$packUint32($_name.length);',
                    '$_name.forEach(\$$_pack);',
                if (optional) '}',
            ]
        ];
    }

    /// Returns code required to unpack this field.
    List<String> get unpack {
        final String ending = type is Message ? '(${type.name}()) as ${type.name}' : '()';
        return <String>[
            if (optional) r'if ($getFlag()) {',
                if (!array) '$name = $_unpack$ending;'
                else ...<String>[
                    '$name = <$_type>[];',
                    'final int ${name}Length = \$unpackUint32();',
                    'for (int i = 0; i < ${name}Length; i++) {',
                        '$_name.add($_unpack$ending);',
                    '}',
                ],
            if (optional) '}',
        ];
    }
}
