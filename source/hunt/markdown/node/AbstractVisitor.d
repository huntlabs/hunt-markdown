module hunt.markdown.node.AbstractVisitor;

import hunt.markdown.node.Node;
import hunt.markdown.node.BlockQuote;
import hunt.markdown.node.BulletList;
import hunt.markdown.node.Code;
import hunt.markdown.node.Document;
import hunt.markdown.node.Emphasis;
import hunt.markdown.node.FencedCodeBlock;
import hunt.markdown.node.HardLineBreak;
import hunt.markdown.node.Heading;
import hunt.markdown.node.ThematicBreak;
import hunt.markdown.node.HtmlInline;
import hunt.markdown.node.HtmlBlock;
import hunt.markdown.node.Image;
import hunt.markdown.node.IndentedCodeBlock;
import hunt.markdown.node.Link;
import hunt.markdown.node.ListItem;
import hunt.markdown.node.OrderedList;
import hunt.markdown.node.Paragraph;
import hunt.markdown.node.SoftLineBreak;
import hunt.markdown.node.StrongEmphasis;
import hunt.markdown.node.Text;
import hunt.markdown.node.CustomBlock;
import hunt.markdown.node.CustomNode;
import hunt.markdown.node.Visitor;

/**
 * Abstract visitor that visits all children by default.
 * <p>
 * Can be used to only process certain nodes. If you override a method and want visiting to descend into children,
 * call {@link #visitChildren}.
 */
abstract class AbstractVisitor : Visitor {

    override public void visit(BlockQuote blockQuote) {
        visitChildren(blockQuote);
    }

    override public void visit(BulletList bulletList) {
        visitChildren(bulletList);
    }

    override public void visit(Code code) {
        visitChildren(code);
    }

    override public void visit(Document document) {
        visitChildren(document);
    }

    override public void visit(Emphasis emphasis) {
        visitChildren(emphasis);
    }

    override public void visit(FencedCodeBlock fencedCodeBlock) {
        visitChildren(fencedCodeBlock);
    }

    override public void visit(HardLineBreak hardLineBreak) {
        visitChildren(hardLineBreak);
    }

    override public void visit(Heading heading) {
        visitChildren(heading);
    }

    override public void visit(ThematicBreak thematicBreak) {
        visitChildren(thematicBreak);
    }

    override public void visit(HtmlInline htmlInline) {
        visitChildren(htmlInline);
    }

    override public void visit(HtmlBlock htmlBlock) {
        visitChildren(htmlBlock);
    }

    override public void visit(Image image) {
        visitChildren(image);
    }

    override public void visit(IndentedCodeBlock indentedCodeBlock) {
        visitChildren(indentedCodeBlock);
    }

    override public void visit(Link link) {
        visitChildren(link);
    }

    override public void visit(ListItem listItem) {
        visitChildren(listItem);
    }

    override public void visit(OrderedList orderedList) {
        visitChildren(orderedList);
    }

    override public void visit(Paragraph paragraph) {
        visitChildren(paragraph);
    }

    override public void visit(SoftLineBreak softLineBreak) {
        visitChildren(softLineBreak);
    }

    override public void visit(StrongEmphasis strongEmphasis) {
        visitChildren(strongEmphasis);
    }

    override public void visit(Text text) {
        visitChildren(text);
    }

    override public void visit(CustomBlock customBlock) {
        visitChildren(customBlock);
    }

    override public void visit(CustomNode customNode) {
        visitChildren(customNode);
    }

    /**
     * Visit the child nodes.
     *
     * @param parent the parent node whose children should be visited
     */
    protected void visitChildren(Node parent) {
        Node node = parent.getFirstChild();
        while (node !is null) {
            // A subclass of this visitor might modify the node, resulting in getNext returning a different node or no
            // node after visiting it. So get the next node before visiting.
            Node next = node.getNext();
            node.accept(this);
            node = next;
        }
    }
}
