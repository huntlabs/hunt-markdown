module hunt.markdown.ext.gfm.strikethrough.internal.StrikethroughTextContentNodeRenderer;

import hunt.markdown.renderer.text.TextContentWriter;
import hunt.markdown.renderer.text.TextContentNodeRendererContext;
import hunt.markdown.node.Node;
import hunt.markdown.ext.gfm.strikethrough.internal.StrikethroughNodeRenderer;

class StrikethroughTextContentNodeRenderer : StrikethroughNodeRenderer {

    private TextContentNodeRendererContext context;
    private TextContentWriter textContent;

    public this(TextContentNodeRendererContext context) {
        this.context = context;
        this.textContent = context.getWriter();
    }

    public void render(Node node) {
        textContent.write('/');
        renderChildren(node);
        textContent.write('/');
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
