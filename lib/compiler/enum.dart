/// This class describes Enum type declared in manifest.

part of packme.compiler;

class Enum {
    Enum(this.name, this.manifest) {
        for (String value in manifest) {
            value = validName(value);
            if (value.isEmpty) throw Exception('Enum "$name" contains invalid value.');
            if (values.contains(value)) throw Exception('Enum "$name" value "$value" is duplicated.');
            values.add(value);
        }
    }

    final String name;
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
