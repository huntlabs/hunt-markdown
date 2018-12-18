module hunt.markdown.renderer.Renderer;

import hunt.markdown.node.Node;

import hunt.lang.common;

public interface Renderer {

    /**
     * Render the tree of nodes to output.
     *
     * @param node the root node
     * @param output output for rendering
     */
    void render(Node node, Appendable output);

    /**
     * Render the tree of nodes to string.
     *
     * @param node the root node
     * @return the rendered string
     */
    string render(Node node);
}
