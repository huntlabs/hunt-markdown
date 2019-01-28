module hunt.markdown.ext.gfm.strikethrough.internal.StrikethroughHtmlNodeRenderer;

import hunt.markdown.renderer.html.HtmlWriter;
import hunt.markdown.renderer.html.HtmlNodeRendererContext;
import hunt.markdown.node.Node;
import hunt.markdown.ext.gfm.strikethrough.internal.StrikethroughNodeRenderer;

import hunt.collection.Collections;
import hunt.collection.Map;

class StrikethroughHtmlNodeRenderer : StrikethroughNodeRenderer {

    private HtmlNodeRendererContext context;
    private HtmlWriter html;

    public this(HtmlNodeRendererContext context) {
        this.context = context;
        this.html = context.getWriter();
    }

    public void render(Node node) {
        Map!(string, string) attributes = context.extendAttributes(node, "del", Collections.emptyMap!(string, string)());
        html.tag("del", attributes);
        renderChildren(node);
        html.tag("/del");
    }

    private void renderChildren(Node parent) {
        Node node = parent.getFirstChild();
        while (node !is null) {
            Node next = node.getNext();
            context.render(node);
            node = next;
        }
    }
}
