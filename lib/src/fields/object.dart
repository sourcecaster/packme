/// This class describes object field of object type { ... }.

part of packme.compiler;

class ObjectField extends Field {
    ObjectField(Node node, String tag, Map<String, dynamic> manifest) :
            embeddedObject = Object(node.container, '${node.tag}_${toSingular(tag)}', manifest),
            super(node, tag, manifest) {
        node.embed(embeddedObject);
    }

    final Object embeddedObject;

    @override
    String get type => embeddedObject.name;

    @override
    String estimator([String name = '']) => '$name.\$estimate()';

    @override
    String packer([String name = '']) => '\$packMessage($name)';

    @override
    String unpacker([String name = '']) => '\$unpackMessage(${embeddedObject.name}.\$empty())';

    List<String> output() => embeddedObject.output();
}