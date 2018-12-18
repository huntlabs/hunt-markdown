module hunt.markdown.renderer.html.HtmlNodeRendererFactory;

import hunt.markdown.renderer.NodeRenderer;

import hunt.markdown.renderer.html.HtmlNodeRendererContext;

/**
 * Factory for instantiating new node renderers when rendering is done.
 */
public interface HtmlNodeRendererFactory {

    /**
     * Create a new node renderer for the specified rendering context.
     *
     * @param context the context for rendering (normally passed on to the node renderer)
     * @return a node renderer
     */
    NodeRenderer create(HtmlNodeRendererContext context);
}
