/// This class describes a single field entry of the object, message or request.

part of packme.compiler;

abstract class Field {
    Field(this.node, this.tag, this.manifest) : name = validName(tag), optional = RegExp(r'^\?').hasMatch(tag) {
        if (name == '') throw Exception('Field "$tag" of node "${node.tag}" in '
            '${node.container.filename}.json is resulted with the name "$name", which is reserved by Dart language.');
        if (isReserved(name)) throw Exception('Field "$tag" of node "${node.tag}" in '
            '${node.container.filename}.json is resulted with the name parsed into an empty string.');
    }

    /// Try to create a Node instance of corresponding type
    static Field fromEntry(Node node, MapEntry<String, dynamic> entry, { bool parentIsArray = false }) {
        if (entry.value is String) {
            final String manifest = entry.value as String;
            if (manifest == 'bool') return BoolField(node, entry.key, manifest);
            if (<String>['int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64', ].contains(manifest)) return IntField(node, entry.key, manifest);
            if (<String>['float', 'double'].contains(manifest)) return FloatField(node, entry.key, manifest);
            if (manifest == 'string') return StringField(node, entry.key, manifest);
            if (manifest == 'datetime') return DateTimeField(node, entry.key, manifest);
            if (RegExp(r'^binary\d+$').hasMatch(manifest)) return BinaryField(node, entry.key, manifest);
            if (RegExp(r'^@.+').hasMatch(manifest)) return ReferenceField(node, entry.key, manifest);
        }
        if (entry.value is List && entry.value.length == 1) return ArrayField(node, entry.key, entry.value as List<dynamic>);
        if (entry.value is Map) return ObjectField(node, entry.key, entry.value as Map<String, dynamic>, parentIsArray: parentIsArray);
        throw Exception('Field "${entry.key}" of node "${node.tag}" in ${node.container.filename}.json has invalid type. '
            'Valid types are: bool, int8, uint8, int16, uint16, int32, uint32, int64, uint64, float, double, datetime, string, binary# (e.g.: "binary16"). '
            'It can also be an array of type (e.g. ["int8"]), a reference to an object (e.g. "@item") or embedded object itself: { <field>: <type>, ... }');
    }

    final Node node;
    final String tag;
    final String name;
    final bool optional;
    final dynamic manifest;

    String get nameEnsured => '$name${optional ? '!' : ''}';
    String get type;
    int get size => 0;

    /// Return corresponding single operation code
    String estimator([String name = '']) => '$size';
    String packer([String name = '']);
    String unpacker([String name = '']);

    /// Get whether it has a fixed footprint (always fixed size in a buffer) or not
    bool get static => !optional && this is! ArrayField && this is! ObjectField && this is! StringField;

    /// Get initializer list declaration code
    String get initializer => '${optional ? '' : 'required '}this.$name,';

    /// Get attribute declaration code
    String get attribute => optional ? '$type? $name,' : 'required $type $name,';

    /// Get property declaration code
    String get declaration => optional ? '$type? $name;' : 'late $type $name;';

    /// Get estimate buffer size code
    List<String> get estimate {
        return static ? <String>[] : <String>[
            if (optional) '\$setFlag($name != null);',
            if (optional) 'if ($name != null) _bytes += ${estimator(nameEnsured)};'
            else '_bytes += ${estimator(name)};',
        ];
    }

    /// Get pack data into buffer code
    List<String> get pack {
        return <String>[
            '${optional ? 'if ($name != null) ' : ''}${packer(nameEnsured)};'
        ];
    }

    /// Get unpack data from buffer code
    List<String> get unpack {
        return <String>[
            '${optional ? r'if ($getFlag()) ' : ''}$name = ${unpacker(nameEnsured)};'
        ];
    }
}
