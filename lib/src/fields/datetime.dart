/// This class describes object field of type datetime.

part of packme.compiler;

class DateTimeField extends Field {
    DateTimeField(Node node, String tag, dynamic manifest) : super(node, tag, manifest);

    @override
    String get type => 'DateTime';

    @override
    int get size => 8;

    @override
    List<String> get pack {
        return <String>[
            '${optional ? 'if ($name != null) ' : ''}\$packDateTime($nameEnsured);'
        ];
    }

    @override
    List<String> get unpack {
        return <String>[
            '${optional ? r'if ($getFlag()) ' : ''}$name = \$unpackDateTime();'
        ];
    }
}