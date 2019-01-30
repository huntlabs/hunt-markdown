module hunt.markdown.renderer.html.CoreHtmlNodeRenderer;

import hunt.markdown.node;
import hunt.markdown.node.AbstractVisitor;
import hunt.markdown.node.Heading;
import hunt.markdown.renderer.NodeRenderer;
import hunt.markdown.renderer.html.HtmlWriter;
import hunt.markdown.renderer.html.HtmlNodeRendererContext;

import hunt.collection.Set;
import hunt.collection.HashSet;
import hunt.collection.Map;
import hunt.collection.LinkedHashMap;
import hunt.collection.Collections;
import hunt.text;
import hunt.text.StringBuilder;

import std.conv;
import std.string;
/**
 * The node renderer that renders all the core nodes (comes last in the order of node renderers).
 */
class CoreHtmlNodeRenderer : AbstractVisitor, NodeRenderer {

    protected HtmlNodeRendererContext context;
    private HtmlWriter html;

    public this(HtmlNodeRendererContext context) {
        this.context = context;
        this.html = context.getWriter();
    }

    public Set!TypeInfo_Class getNodeTypes() {
        return new HashSet!TypeInfo_Class([
                typeid(Document),
                typeid(Heading),
                typeid(Paragraph),
                typeid(BlockQuote),
                typeid(BulletList),
                typeid(FencedCodeBlock),
                typeid(HtmlBlock),
                typeid(ThematicBreak),
                typeid(IndentedCodeBlock),
                typeid(Link),
                typeid(ListItem),
                typeid(OrderedList),
                typeid(Image),
                typeid(Emphasis),
                typeid(StrongEmphasis),
                typeid(Text),
                typeid(Code),
                typeid(HtmlInline),
                typeid(SoftLineBreak),
                typeid(HardLineBreak)
        ]);
    }

    public void render(Node node) {
        node.accept(this);
    }

    override public void visit(Document document) {
        // No rendering itself
        visitChildren(document);
    }

    override public void visit(Heading heading) {
        string htag = "h" ~ heading.getLevel().to!string;
        html.line();
        html.tag(htag, getAttrs(heading, htag));
        visitChildren(heading);
        html.tag('/' ~ htag);
        html.line();
    }

    override public void visit(Paragraph paragraph) {
        bool inTightList = isInTightList(paragraph);
        if (!inTightList) {
            html.line();
            html.tag("p", getAttrs(paragraph, "p"));
        }
        visitChildren(paragraph);
        if (!inTightList) {
            html.tag("/p");
            html.line();
        }
    }

    override public void visit(BlockQuote blockQuote) {
        html.line();
        html.tag("blockquote", getAttrs(blockQuote, "blockquote"));
        html.line();
        visitChildren(blockQuote);
        html.line();
        html.tag("/blockquote");
        html.line();
    }

    override public void visit(BulletList bulletList) {
        renderListBlock(bulletList, "ul", getAttrs(bulletList, "ul"));
    }

    override public void visit(FencedCodeBlock fencedCodeBlock) {
        string literal = fencedCodeBlock.getLiteral();
        Map!(string, string) attributes = new LinkedHashMap!(string, string)();
        string info = fencedCodeBlock.getInfo();
        if (info !is null && !info.isEmpty()) {
            int space = cast(int)(info.indexOf(" "));
            string language;
            if (space == -1) {
                language = info;
            } else {
                language = info.substring(0, space);
            }
            attributes.put("class", "language-" ~ language);
        }
        renderCodeBlock(literal, fencedCodeBlock, attributes);
    }

    override public void visit(HtmlBlock htmlBlock) {
        html.line();
        if (context.shouldEscapeHtml()) {
            html.tag("p", getAttrs(htmlBlock, "p"));
            html.text(htmlBlock.getLiteral());
            html.tag("/p");
        } else {
            html.raw(htmlBlock.getLiteral());
        }
        html.line();
    }

    override public void visit(ThematicBreak thematicBreak) {
        html.line();
        html.tag("hr", getAttrs(thematicBreak, "hr"), true);
        html.line();
    }

    override public void visit(IndentedCodeBlock indentedCodeBlock) {
        renderCodeBlock(indentedCodeBlock.getLiteral(), indentedCodeBlock, Collections.emptyMap!(string, string)());
    }

    override public void visit(Link link) {
        Map!(string, string) attrs = new LinkedHashMap!(string, string)();
        string url = context.encodeUrl(link.getDestination());
        attrs.put("href", url);
        if (link.getTitle() !is null) {
            attrs.put("title", link.getTitle());
        }
        html.tag("a", getAttrs(link, "a", attrs));
        visitChildren(link);
        html.tag("/a");
    }

    override public void visit(ListItem listItem) {
        html.tag("li", getAttrs(listItem, "li"));
        visitChildren(listItem);
        html.tag("/li");
        html.line();
    }

    override public void visit(OrderedList orderedList) {
        int start = orderedList.getStartNumber();
        Map!(string, string) attrs = new LinkedHashMap!(string, string)();
        if (start != 1) {
            attrs.put("start", to!string(start));
        }
        renderListBlock(orderedList, "ol", getAttrs(orderedList, "ol", attrs));
    }

    override public void visit(Image image) {
        string url = context.encodeUrl(image.getDestination());

        AltTextVisitor altTextVisitor = new AltTextVisitor();
        image.accept(altTextVisitor);
        string altText = altTextVisitor.getAltText();

        Map!(string, string) attrs = new LinkedHashMap!(string, string)();
        attrs.put("src", url);
        attrs.put("alt", altText);
        if (image.getTitle() !is null) {
            attrs.put("title", image.getTitle());
        }

        html.tag("img", getAttrs(image, "img", attrs), true);
    }

    override public void visit(Emphasis emphasis) {
        html.tag("em", getAttrs(emphasis, "em"));
        visitChildren(emphasis);
        html.tag("/em");
    }

    override public void visit(StrongEmphasis strongEmphasis) {
        html.tag("strong", getAttrs(strongEmphasis, "strong"));
        visitChildren(strongEmphasis);
        html.tag("/strong");
    }

    override public void visit(Text text) {
        html.text(text.getLiteral());
    }

    override public void visit(Code code) {
        html.tag("code", getAttrs(code, "code"));
        html.text(code.getLiteral());
        html.tag("/code");
    }

    override public void visit(HtmlInline htmlInline) {
        if (context.shouldEscapeHtml()) {
            html.text(htmlInline.getLiteral());
        } else {
            html.raw(htmlInline.getLiteral());
        }
    }

    override public void visit(SoftLineBreak softLineBreak) {
        html.raw(context.getSoftbreak());
    }

    override public void visit(HardLineBreak hardLineBreak) {
        html.tag("br", getAttrs(hardLineBreak, "br"), true);
        html.line();
    }

    override protected void visitChildren(Node parent) {
        Node node = parent.getFirstChild();
        while (node !is null) {
            Node next = node.getNext();
            context.render(node);
            node = next;
        }
    }

    private void renderCodeBlock(string literal, Node node, Map!(string, string) attributes) {
        html.line();
        html.tag("pre", getAttrs(node, "pre"));
        html.tag("code", getAttrs(node, "code", attributes));
        html.text(literal);
        html.tag("/code");
        html.tag("/pre");
        html.line();
    }

    private void renderListBlock(ListBlock listBlock, string tagName, Map!(string, string) attributes) {
        html.line();
        html.tag(tagName, attributes);
        html.line();
        visitChildren(listBlock);
        html.line();
        html.tag('/' ~ tagName);
        html.line();
    }

    private bool isInTightList(Paragraph paragraph) {
        Node parent = paragraph.getParent();
        if (parent !is null) {
            Node gramps = parent.getParent();
            if (gramps !is null && cast(ListBlock)gramps !is null) {
                ListBlock list = cast(ListBlock) gramps;
                return list.isTight();
            }
        }
        return false;
    }

    private Map!(string, string) getAttrs(Node node, string tagName) {
        return getAttrs(node, tagName, Collections.emptyMap!(string, string)());
    }

    private Map!(string, string) getAttrs(Node node, string tagName, Map!(string, string) defaultAttributes) {
        return context.extendAttributes(node, tagName, defaultAttributes);
    }

    private static class AltTextVisitor : AbstractVisitor {

        private StringBuilder sb;

        this()
        {
            sb = new StringBuilder();
        }

        string getAltText() {
            return sb.toString();
        }

        override public void visit(Text text) {
            sb.append(text.getLiteral());
        }

        override public void visit(SoftLineBreak softLineBreak) {
            sb.append('\n');
        }

        override public void visit(HardLineBreak hardLineBreak) {
            sb.append('\n');
        }
    }
}
