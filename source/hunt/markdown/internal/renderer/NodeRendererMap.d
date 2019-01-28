module hunt.markdown.internal.renderer.NodeRendererMap;

import hunt.markdown.node.Node;
import hunt.markdown.renderer.NodeRenderer;

import hunt.collection.HashMap;
import hunt.collection.Map;

class NodeRendererMap {

    private Map!(TypeInfo_Class, NodeRenderer) renderers;

    this()
    {
        renderers = new HashMap!(TypeInfo_Class, NodeRenderer)(32);
    }

    // public void add(NodeRenderer nodeRenderer) {
    //     for (Class<? : Node> nodeType : nodeRenderer.getNodeTypes()) {
    //         // Overwrite existing renderer
    //         renderers.put(nodeType, nodeRenderer);
    //     }
    // }

    public void add(NodeRenderer nodeRenderer) {
        foreach (nodeType ; nodeRenderer.getNodeTypes()) {
            // Overwrite existing renderer
            renderers.put(nodeType, nodeRenderer);
        }
    }

    public void render(Node node) {
        NodeRenderer nodeRenderer = renderers.get(typeid(node));
        if (nodeRenderer !is null) {
            nodeRenderer.render(node);
        }
    }
}
