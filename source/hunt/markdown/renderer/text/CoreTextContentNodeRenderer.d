module hunt.markdown.renderer.text.CoreTextContentNodeRenderer;

import hunt.markdown.node;
import hunt.markdown.node.Heading;
import hunt.markdown.node.AbstractVisitor;
import hunt.markdown.renderer.NodeRenderer;
import hunt.markdown.renderer.text.TextContentNodeRendererContext;
import hunt.markdown.renderer.text.TextContentWriter;
import hunt.markdown.internal.renderer.text.BulletListHolder;
import hunt.markdown.internal.renderer.text.ListHolder;
import hunt.markdown.internal.renderer.text.OrderedListHolder;

import hunt.container.HashSet;
import hunt.container.Set;
import hunt.lang.character;

/**
 * The node renderer that renders all the core nodes (comes last in the order of node renderers).
 */
class CoreTextContentNodeRenderer : AbstractVisitor, NodeRenderer {

    protected TextContentNodeRendererContext context;
    private TextContentWriter textContent;

    private ListHolder listHolder;

    public this(TextContentNodeRendererContext context) {
        this.context = context;
        this.textContent = context.getWriter();
    }

    override public Set!Node getNodeTypes() {
        return new HashSet!Node([
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

    override public void visit(BlockQuote blockQuote) {
        textContent.write('«');
        visitChildren(blockQuote);
        textContent.write('»');

        writeEndOfLineIfNeeded(blockQuote, null);
    }

    override public void visit(BulletList bulletList) {
        if (listHolder !is null) {
            writeEndOfLine();
        }
        listHolder = new BulletListHolder(listHolder, bulletList);
        visitChildren(bulletList);
        writeEndOfLineIfNeeded(bulletList, null);
        if (listHolder.getParent() !is null) {
            listHolder = listHolder.getParent();
        } else {
            listHolder = null;
        }
    }

    override public void visit(Code code) {
        textContent.write('\"');
        textContent.write(code.getLiteral());
        textContent.write('\"');
    }

    override public void visit(FencedCodeBlock fencedCodeBlock) {
        if (context.stripNewlines()) {
            textContent.writeStripped(fencedCodeBlock.getLiteral());
            writeEndOfLineIfNeeded(fencedCodeBlock, null);
        } else {
            textContent.write(fencedCodeBlock.getLiteral());
        }
    }

    override public void visit(HardLineBreak hardLineBreak) {
        writeEndOfLineIfNeeded(hardLineBreak, null);
    }

    override public void visit(Heading heading) {
        visitChildren(heading);
        writeEndOfLineIfNeeded(heading, ':');
    }

    override public void visit(ThematicBreak thematicBreak) {
        if (!context.stripNewlines()) {
            textContent.write("***");
        }
        writeEndOfLineIfNeeded(thematicBreak, null);
    }

    override public void visit(HtmlInline htmlInline) {
        writeText(htmlInline.getLiteral());
    }

    override public void visit(HtmlBlock htmlBlock) {
        writeText(htmlBlock.getLiteral());
    }

    override public void visit(Image image) {
        writeLink(image, image.getTitle(), image.getDestination());
    }

    override public void visit(IndentedCodeBlock indentedCodeBlock) {
        if (context.stripNewlines()) {
            textContent.writeStripped(indentedCodeBlock.getLiteral());
            writeEndOfLineIfNeeded(indentedCodeBlock, null);
        } else {
            textContent.write(indentedCodeBlock.getLiteral());
        }
    }

    override public void visit(Link link) {
        writeLink(link, link.getTitle(), link.getDestination());
    }

    override public void visit(ListItem listItem) {
        if (listHolder !is null && cast(OrderedListHolder)listHolder !is null) {
            OrderedListHolder orderedListHolder = cast(OrderedListHolder) listHolder;
            string indent = context.stripNewlines() ? "" : orderedListHolder.getIndent();
            textContent.write(indent ~ orderedListHolder.getCounter() + orderedListHolder.getDelimiter() + " ");
            visitChildren(listItem);
            writeEndOfLineIfNeeded(listItem, null);
            orderedListHolder.increaseCounter();
        } else if (listHolder !is null && cast(BulletListHolder)listHolder !is null) {
            BulletListHolder bulletListHolder = cast(BulletListHolder) listHolder;
            if (!context.stripNewlines()) {
                textContent.write(bulletListHolder.getIndent() + bulletListHolder.getMarker() + " ");
            }
            visitChildren(listItem);
            writeEndOfLineIfNeeded(listItem, null);
        }
    }

    override public void visit(OrderedList orderedList) {
        if (listHolder !is null) {
            writeEndOfLine();
        }
        listHolder = new OrderedListHolder(listHolder, orderedList);
        visitChildren(orderedList);
        writeEndOfLineIfNeeded(orderedList, null);
        if (listHolder.getParent() !is null) {
            listHolder = listHolder.getParent();
        } else {
            listHolder = null;
        }
    }

    override public void visit(Paragraph paragraph) {
        visitChildren(paragraph);
        // Add "end of line" only if its "root paragraph.
        if (paragraph.getParent() is null || cast(Document)paragraph.getParent() !is null) {
            writeEndOfLineIfNeeded(paragraph, null);
        }
    }

    override public void visit(SoftLineBreak softLineBreak) {
        writeEndOfLineIfNeeded(softLineBreak, null);
    }

    override public void visit(Text text) {
        writeText(text.getLiteral());
    }

    override protected void visitChildren(Node parent) {
        Node node = parent.getFirstChild();
        while (node !is null) {
            Node next = node.getNext();
            context.render(node);
            node = next;
        }
    }

    private void writeText(string text) {
        if (context.stripNewlines()) {
            textContent.writeStripped(text);
        } else {
            textContent.write(text);
        }
    }

    private void writeLink(Node node, string title, string destination) {
        bool hasChild = node.getFirstChild() !is null;
        bool hasTitle = title !is null && !title == destination;
        bool hasDestination = destination !is null && !destination.equals("");

        if (hasChild) {
            textContent.write('"');
            visitChildren(node);
            textContent.write('"');
            if (hasTitle || hasDestination) {
                textContent.whitespace();
                textContent.write('(');
            }
        }

        if (hasTitle) {
            textContent.write(title);
            if (hasDestination) {
                textContent.colon();
                textContent.whitespace();
            }
        }

        if (hasDestination) {
            textContent.write(destination);
        }

        if (hasChild && (hasTitle || hasDestination)) {
            textContent.write(')');
        }
    }

    private void writeEndOfLineIfNeeded(Node node, Character c) {
        if (context.stripNewlines()) {
            if (c !is null) {
                textContent.write(c);
            }
            if (node.getNext() !is null) {
                textContent.whitespace();
            }
        } else {
            if (node.getNext() !is null) {
                textContent.line();
            }
        }
    }

    private void writeEndOfLine() {
        if (context.stripNewlines()) {
            textContent.whitespace();
        } else {
            textContent.line();
        }
    }
}
