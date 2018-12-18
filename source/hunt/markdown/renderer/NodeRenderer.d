module hunt.markdown.renderer.NodeRenderer;

import hunt.markdown.node.Node;

import hunt.container.Set;

/**
 * A renderer for a set of node types.
 */
public interface NodeRenderer {

    /**
     * @return the types of nodes that this renderer handles
     */
    Set!Node getNodeTypes();

    /**
     * Render the specified node.
     *
     * @param node the node to render, will be an instance of one of {@link #getNodeTypes()}
     */
    void render(Node node);
}
