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
        final List<String> code = <String>[];
        if (optional) code.add('		\$setFlag($name != null);');
        if (optional) code.add('		if ($name != null) {');
        if (!array) {
            if (type is String && type != 'string') code.add('${optional ? '	' : ''}		bytes += ${sizeOf[type]};');
            else if (type == 'string') code.add('${optional ? '	' : ''}		bytes += \$stringBytes($_name);');
            else if (type is Message) code.add('${optional ? '	' : ''}		bytes += $_name.\$estimate();');
            else throw Exception('Wrong type "$type" for field "$name"');
        }
        else {
            code.add('		${optional ? '	' : ''}bytes += 4;');
            if (type is String && type != 'string') code.add('${optional ? '	' : ''}		bytes += ${sizeOf[type]} * $_name.length;');
            else if (type == 'string') code.add('${optional ? '	' : ''}		for (int i = 0; i < $_name.length; i++) bytes += \$stringBytes($_name[i]);');
            else if (type is Message) code.add('${optional ? '	' : ''}		for (int i = 0; i < $_name.length; i++) bytes += $_name[i].\$estimate();');
            else throw Exception('Wrong type "$type" for field "$name"');
        }
        if (optional) code.add('		}');
        return code;
    }

    /// Returns code required to pack this field.
    List<String> get pack {
        final List<String> code = <String>[];
        if (!array) {
            code.add('		${optional ? 'if ($name != null) ' : ''}\$$_pack($_name);');
        }
        else {
            if (optional) code.add('		if ($name != null) {');
            code.add('${optional ? '	' : ''}		\$packUint32($_name.length);');
            code.add('${optional ? '	' : ''}		$_name.forEach(\$$_pack);');
            if (optional) code.add('		}');
        }
        return code;
    }

    /// Returns code required to unpack this field.
    List<String> get unpack {
        final List<String> code = <String>[];
        final String ending = type is Message ? '(${type.name}()) as ${type.name}' : '()';
        if (optional) code.add(r'		if ($getFlag()) {');
        if (!array) {
            code.add('${optional ? '	' : ''}		$name = $_unpack$ending;');
        }
        else {
            code.add('${optional ? '	' : ''}		$name = <$_type>[];');
            code.add('${optional ? '	' : ''}		final int ${name}Length = \$unpackUint32();');
            code.add('${optional ? '	' : ''}		for (int i = 0; i < ${name}Length; i++) {');
            code.add('${optional ? '	' : ''}			$_name.add($_unpack$ending);');
            code.add('${optional ? '	' : ''}		}');
        }
        if (optional) code.add('		}');
        return code;
    }
}
