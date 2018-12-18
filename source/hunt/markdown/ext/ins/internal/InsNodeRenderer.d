module hunt.markdown.ext.ins.internal.InsNodeRenderer;

import hunt.markdown.ext.ins.Ins;
import hunt.markdown.renderer.html.HtmlWriter;
import hunt.markdown.renderer.html.HtmlNodeRendererContext;
import hunt.markdown.node.Node;
import hunt.markdown.renderer.NodeRenderer;

import hunt.container.Collections;
import hunt.container.Map;
import hunt.container.Set;

class InsNodeRenderer : NodeRenderer {

    private HtmlNodeRendererContext context;
    private HtmlWriter html;

    public this(HtmlNodeRendererContext context) {
        this.context = context;
        this.html = context.getWriter();
    }

    override public Set!(Node) getNodeTypes() {
        return Collections.singleton!(Node)();
    }

    override public void render(Node node) {
        Map!(string, string) attributes = context.extendAttributes(node, "ins", Collections.emptyMap!(string, string)());
        html.tag("ins", attributes);
        renderChildren(node);
        html.tag("/ins");
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
