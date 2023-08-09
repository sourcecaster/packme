/// This class describes a single field entry of the object, message or request.

part of packme.compiler;

abstract class Field {
    Field(this.node, this.tag, this.manifest) : name = validName(tag), optional = tag.substring(0, 1) == '?' {
        if (name == '') throw Exception('Field "$tag" of node "${node.tag}" in file'
            ' "${node.filename}" is resulted with the name "$name", which is reserved by Dart language.');
        if (isReserved(name)) throw Exception('Field "$tag" of node "${node.tag}" in file'
            ' "${node.filename}" is resulted with the name parsed into an empty string.');
    }

    /// Try to create a Node instance of corresponding type
    static Field fromEntry(Node node, MapEntry<String, dynamic> entry) {
        if (entry.value is String) {
            final String value = entry.value as String;
            if (value == 'bool') return BoolField(node, entry.key, value);
            if (value == 'int8') return IntField(node, entry.key, value, signed: true, bytes: 1);
            if (value == 'uint8') return IntField(node, entry.key, value, signed: false, bytes: 1);
            if (value == 'int16') return IntField(node, entry.key, value, signed: true, bytes: 2);
            if (value == 'uint16') return IntField(node, entry.key, value, signed: false, bytes: 2);
            if (value == 'int32') return IntField(node, entry.key, value, signed: true, bytes: 4);
            if (value == 'uint32') return IntField(node, entry.key, value, signed: false, bytes: 4);
            if (value == 'int64') return IntField(node, entry.key, value, signed: true, bytes: 8);
            if (value == 'uint64') return IntField(node, entry.key, value, signed: false, bytes: 8);
            if (value == 'float') return FloatField(node, entry.key, value, bytes: 4);
            if (value == 'double') return FloatField(node, entry.key, value, bytes: 8);
            if (value == 'string') return StringField(node, entry.key, value);
            if (value == 'datetime') return DateTimeField(node, entry.key, value);
            if (RegExp(r'^binary\d+$').hasMatch(value)) return BinaryField(node, entry.key, value, bytes: int.parse(value.substring(6)));
            if (RegExp(r'^@').hasMatch(value)) return ReferenceField(node, entry.key, value.substring(1));
        }
        if (entry.value is List) return ArrayField(node, entry.key, entry.value);
        if (entry.value is Map) return ObjectField(node, entry.key, entry.value);
        throw Exception('Field "${entry.key}" of node "${node.tag}" in file "${node.filename}" has invalid type. '
            'Valid types are: bool, int8, uint8, int16, uint16, int32, uint32, int64, uint64, float, double, datetime, string, binary# (e.g.: "binary16"). '
            'It can also be an array of type (e.g. ["int8"]), a reference to an object (e.g. "@item") or embedded object itself: { <field>: <type>, ... }');
    }

    final Node node;
    final String tag;
    final String name;
    final bool optional;
    final dynamic manifest;

    String get nameEnsured => '$name${optional ? '!' : ''}';
    String get type => '';
    int get size => 0;

    bool get static => !optional && this is! ArrayField && this is! ObjectField && this is! ReferenceField && this is! StringField;

    /// Get initializer list declaration code
    String get initializer => '${optional ? '' : 'required '}this.$name,';

    /// Get attribute declaration code
    String get attribute => optional ? '$type? $name' : 'required $type $name,';

    /// Get property declaration code
    String get declaration => optional ? '$type? $name;' : 'late $type $name;';

    /// Get estimate buffer size code
    List<String> get estimate {
        return static ? <String>[] : <String>[
            '\$setFlag($name != null);',
            'if ($name != null) bytes += $size;',
        ];
    }

    /// Get pack data into buffer code
    List<String> get pack;

    /// Get unpack data from buffer code
    List<String> get unpack;
}
