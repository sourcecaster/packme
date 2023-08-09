/// This class describes object field of type int8/uint8/int16/uint16/int32/uint32/int64/uint64.

part of packme.compiler;

class IntField extends Field {
    IntField(Node node, String tag, dynamic manifest, { required this.signed, required this.bytes }) : super(node, tag, manifest);

    final bool signed;
    final int bytes;

    @override
    String get type => 'int';

    @override
    int get size => bytes;

    @override
    List<String> get pack {
        return <String>[
            '${optional ? 'if ($name != null) ' : ''}\$pack${signed ? 'Int' : 'Uint'}${bytes * 8}($nameEnsured);'
        ];
    }

    @override
    List<String> get unpack {
        return <String>[
            '${optional ? r'if ($getFlag()) ' : ''}$name = \$unpack${signed ? 'Int' : 'Uint'}${bytes * 8}();'
        ];
    }
}