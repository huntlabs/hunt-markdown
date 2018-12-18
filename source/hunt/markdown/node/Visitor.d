module hunt.markdown.node.Visitor;

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

/**
 * Node visitor.
 * <p>
 * See {@link AbstractVisitor} for a base class that can be extended.
 */
public interface Visitor {

    void visit(BlockQuote blockQuote);

    void visit(BulletList bulletList);

    void visit(Code code);

    void visit(Document document);

    void visit(Emphasis emphasis);

    void visit(FencedCodeBlock fencedCodeBlock);

    void visit(HardLineBreak hardLineBreak);

    void visit(Heading heading);

    void visit(ThematicBreak thematicBreak);

    void visit(HtmlInline htmlInline);

    void visit(HtmlBlock htmlBlock);

    void visit(Image image);

    void visit(IndentedCodeBlock indentedCodeBlock);

    void visit(Link link);

    void visit(ListItem listItem);

    void visit(OrderedList orderedList);

    void visit(Paragraph paragraph);

    void visit(SoftLineBreak softLineBreak);

    void visit(StrongEmphasis strongEmphasis);

    void visit(Text text);

    void visit(CustomBlock customBlock);

    void visit(CustomNode customNode);
}
