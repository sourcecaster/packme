/// This class describes object field of reference type @[filename:]<node>.

part of packme.compiler;

class ReferenceField extends Field {
    ReferenceField(Node node, String tag, String manifest) :
            filename = manifest.indexOf(':') > 1 ? manifest.substring(1, manifest.indexOf(':')) : node.container.filename,
            external = manifest.indexOf(':') > 1 && manifest.substring(1, manifest.indexOf(':')) != node.container.filename,
            referenceTag = manifest.indexOf(':') > 1 ? manifest.substring(manifest.indexOf(':') + 1) : manifest.substring(1),
            super(node, tag, manifest) {
        if (referenceTag.isEmpty) {
            throw Exception('Field "$tag" of node "${node.tag}" in ${node.container.filename}.json has reference filename '
                '"$filename.json" but no reference node.');
        }
        if (filename != node.container.filename) node.include(filename, referenceTag);
    }

    final String filename;
    final bool external;
    final String referenceTag;

    Node get referenceNode {
        if (!node.container.containers.containsKey(filename)) {
            throw Exception('Field "$tag" of node "${node.tag}" in ${node.container.filename}.json refers to file '
                '"$filename.json" which is not found within the current compilation process.');
        }
        try {
            return node.container.containers[filename]!.nodes.firstWhere((Node n) => (n is Enum || n is Object) && n.tag == referenceTag);
        }
        catch (err) {
            throw Exception('Field "$tag" of node "${node.tag}" in ${node.container.filename}.json refers to node '
                '"$referenceTag" in $filename.json, but such enum/object node does not exist.');
        }
    }

    @override
    String get type => referenceNode.name;

    @override
    int get size => static ? 1 : 0;

    @override
    bool get static => !optional && referenceNode is Enum;

    @override
    String estimator([String name = '']) => referenceNode is Enum
        ? '1'
        : '$name.\$estimate()';

    @override
    String packer([String name = '']) => referenceNode is Enum
        ? '\$packUint8($name.index)'
        : '\$packMessage($name)';

    @override
    String unpacker([String name = '']) => referenceNode is Enum
        ? '${referenceNode.name}.values[\$unpackUint8()]'
        : referenceNode is Object && ((referenceNode as Object).inheritTag.isNotEmpty || (referenceNode as Object)._getChildObjects().isNotEmpty)
            ? '\$unpackMessage(${(referenceNode as Object)._getInheritedRoot().name}.\$emptyKin(\$unpackUint32()))'
                + ((referenceNode as Object)._getInheritedRoot() != referenceNode ? ' as ${referenceNode.name}' : '')
            : '\$unpackMessage(${referenceNode.name}.\$empty())';
}