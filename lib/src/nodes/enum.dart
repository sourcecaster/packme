/// This class describes enum node declared in manifest.

part of packme.compiler;

class Enum extends Node {
    Enum(Container container, String tag, List<dynamic> manifest) : super(container, tag, validName(tag, firstCapital: true), manifest) {
        if (isReserved(name)) {
            throw Exception('Enum node "$tag" in ${container.filename}.json is resulted with the name "$name", which is reserved by Dart language.');
        }
        for (final dynamic row in manifest) {
            final String string = row as String;
            final String value = validName(string);
            if (value.isEmpty) throw Exception('Enum declaration "$tag" in ${container.filename}.json contains invalid value "$string" which is parsed into an empty string.');
            if (values.contains(value)) throw Exception('Enum declaration "$tag" in ${container.filename}.json value "$string" is parsed into a duplicating value "$value".');
            if (isReserved(value)) throw Exception('Enum declaration "$tag" in ${container.filename}.json value "$string" is parsed as "$value" which is reserved by Dart language.');
            values.add(value);
        }
    }

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