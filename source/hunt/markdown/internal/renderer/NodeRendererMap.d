module hunt.markdown.internal.renderer.NodeRendererMap;

import hunt.markdown.node.Node;
import hunt.markdown.renderer.NodeRenderer;

import hunt.container.HashMap;
import hunt.container.Map;

class NodeRendererMap {

    private Map!(Node, NodeRenderer) renderers;

    this()
    {
        renderers = new HashMap!(Node, NodeRenderer)(32);
    }

    // public void add(NodeRenderer nodeRenderer) {
    //     for (Class<? : Node> nodeType : nodeRenderer.getNodeTypes()) {
    //         // Overwrite existing renderer
    //         renderers.put(nodeType, nodeRenderer);
    //     }
    // }

    public void add(NodeRenderer nodeRenderer) {
        foreach (Node nodeType ; nodeRenderer.getNodeTypes()) {
            // Overwrite existing renderer
            renderers.put(nodeType, nodeRenderer);
        }
    }

    public void render(Node node) {
        NodeRenderer nodeRenderer = renderers.get(node.getClass());
        if (nodeRenderer !is null) {
            nodeRenderer.render(node);
        }
    }
}
