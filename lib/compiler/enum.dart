/// This class describes Enum type declared in manifest.

part of packme.compiler;

class Enum extends FieldType {
    Enum(String filename, String name, this.manifest) : super(filename, name) {
        for (String value in manifest) {
            value = validName(value);
            if (value.isEmpty) throw Exception('Enum "$name" contains invalid value.');
            if (values.contains(value)) throw Exception('Enum "$name" value "$value" is duplicated.');
            if (reserved.contains(value)) throw Exception('Enum "$name" value "$value" is reserved by Dart.');
            values.add(value);
        }
    }

    final List<String> manifest;
    final List<String> values = <String>[];

    /// Return resulting code for Enum.
    List<String> output() {
        return <String>[
            'enum $name {',
            ...values.map((String value) => '$value,'),
            '}\n',
        ];
    }
}
