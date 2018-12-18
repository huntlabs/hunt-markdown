module hunt.markdown.ext.table.internal.TableTextContentNodeRenderer;

import hunt.markdown.ext.table.TableBlock;
import hunt.markdown.ext.table.TableBody;
import hunt.markdown.ext.table.TableCell;
import hunt.markdown.ext.table.TableHead;
import hunt.markdown.ext.table.TableRow;
import hunt.markdown.node.Node;
import hunt.markdown.renderer.text.TextContentNodeRendererContext;
import hunt.markdown.renderer.text.TextContentWriter;

/**
 * The Table node renderer that is needed for rendering GFM tables (GitHub Flavored Markdown) to text content.
 */
class TableTextContentNodeRenderer : TableNodeRenderer {

    private TextContentWriter textContentWriter;
    private TextContentNodeRendererContext context;

    public this(TextContentNodeRendererContext context) {
        this.textContentWriter = context.getWriter();
        this.context = context;
    }

    protected void renderBlock(TableBlock tableBlock) {
        renderChildren(tableBlock);
        if (tableBlock.getNext() !is null) {
            textContentWriter.write("\n");
        }
    }

    protected void renderHead(TableHead tableHead) {
        renderChildren(tableHead);
    }

    protected void renderBody(TableBody tableBody) {
        renderChildren(tableBody);
    }

    protected void renderRow(TableRow tableRow) {
        textContentWriter.line();
        renderChildren(tableRow);
        textContentWriter.line();
    }

    protected void renderCell(TableCell tableCell) {
        renderChildren(tableCell);
        textContentWriter.write('|');
        textContentWriter.whitespace();
    }

    private void renderLastCell(TableCell tableCell) {
        renderChildren(tableCell);
    }

    private void renderChildren(Node parent) {
        Node node = parent.getFirstChild();
        while (node !is null) {
            Node next = node.getNext();
            // For last cell in row, we dont render the delimiter.
            if (cast(TableCell)node !is null && next is null) {
                renderLastCell(cast(TableCell) node);
            } else {
                context.render(node);
            }

            node = next;
        }
    }
}
