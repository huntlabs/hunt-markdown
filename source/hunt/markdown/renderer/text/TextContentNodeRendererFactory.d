module hunt.markdown.renderer.text.TextContentNodeRendererFactory;

import hunt.markdown.renderer.NodeRenderer;
import hunt.markdown.renderer.text.TextContentNodeRendererContext;

/**
 * Factory for instantiating new node renderers when rendering is done.
 */
public interface TextContentNodeRendererFactory {

    /**
     * Create a new node renderer for the specified rendering context.
     *
     * @param context the context for rendering (normally passed on to the node renderer)
     * @return a node renderer
     */
    NodeRenderer create(TextContentNodeRendererContext context);
}
