module hunt.markdown.renderer.html.HtmlNodeRendererContext;

import hunt.markdown.node.Node;
import hunt.markdown.renderer.html.HtmlWriter;

import hunt.container.Map;

public interface HtmlNodeRendererContext {

    /**
     * @param url to be encoded
     * @return an encoded URL (depending on the configuration)
     */
    string encodeUrl(string url);

    /**
     * Let extensions modify the HTML tag attributes.
     *
     * @param node the node for which the attributes are applied
     * @param tagName the HTML tag name that these attributes are for (e.g. {@code h1}, {@code pre}, {@code code}).
     * @param attributes the attributes that were calculated by the renderer
     * @return the extended attributes with added/updated/removed entries
     */
    Map!(string, string) extendAttributes(Node node, string tagName, Map!(string, string) attributes);

    /**
     * @return the HTML writer to use
     */
    HtmlWriter getWriter();

    /**
     * @return HTML that should be rendered for a soft line break
     */
    string getSoftbreak();

    /**
     * Render the specified node and its children using the configured renderers. This should be used to render child
     * nodes; be careful not to pass the node that is being rendered, that would result in an endless loop.
     *
     * @param node the node to render
     */
    void render(Node node);

    /**
     * @return whether HTML blocks and tags should be escaped or not
     */
    bool shouldEscapeHtml();
}
