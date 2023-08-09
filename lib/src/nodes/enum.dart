/// This class describes enum node declared in manifest.

part of packme.compiler;

class Enum extends Node {
    Enum(String filename, String tag, dynamic manifest) : name = validName(tag, firstCapital: true), super(filename, tag, manifest) {
        if (isReserved(name)) {
            throw Exception('Enum node "$tag" in file "$filename" is resulted with the name "$name", which is reserved by Dart language.');
        }
        for (final String string in manifest) {
            final String value = validName(string);
            if (value.isEmpty) throw Exception('Enum declaration "$tag" in file "$filename" contains invalid value "$string" which is parsed into an empty string.');
            if (values.contains(value)) throw Exception('Enum declaration "$tag" in file "$filename" value "$string" is parsed into a duplicating value "$value".');
            if (isReserved(value)) throw Exception('Enum declaration "$tag" in file "$filename" value "$string" is parsed as "$value" which is reserved by Dart language.');
            values.add(value);
        }
    }

    final String name;
    final List<String> values = <String>[];

    /// Return resulting code for Enum.
    @override
    List<String> output() {
        return <String>[
            '',
            'enum $name {',
            ...values.map((String value) => '$value,'),
            '}',
        ];
    }
}