module hunt.markdown.ext.table.internal.TableHtmlNodeRenderer;

import hunt.container.Collections;
import hunt.container.Map;

import hunt.markdown.ext.table.TableBlock;
import hunt.markdown.ext.table.TableBody;
import hunt.markdown.ext.table.TableCell;
import hunt.markdown.ext.table.TableHead;
import hunt.markdown.ext.table.TableRow;
import hunt.markdown.node.Node;
import hunt.markdown.renderer.html.HtmlNodeRendererContext;
import hunt.markdown.renderer.html.HtmlWriter;

class TableHtmlNodeRenderer : TableNodeRenderer {

    private HtmlWriter htmlWriter;
    private HtmlNodeRendererContext context;

    public this(HtmlNodeRendererContext context) {
        this.htmlWriter = context.getWriter();
        this.context = context;
    }

    protected void renderBlock(TableBlock tableBlock) {
        htmlWriter.line();
        htmlWriter.tag("table", getAttributes(tableBlock, "table"));
        renderChildren(tableBlock);
        htmlWriter.tag("/table");
        htmlWriter.line();
    }

    protected void renderHead(TableHead tableHead) {
        htmlWriter.line();
        htmlWriter.tag("thead", getAttributes(tableHead, "thead"));
        renderChildren(tableHead);
        htmlWriter.tag("/thead");
        htmlWriter.line();
    }

    protected void renderBody(TableBody tableBody) {
        htmlWriter.line();
        htmlWriter.tag("tbody", getAttributes(tableBody, "tbody"));
        renderChildren(tableBody);
        htmlWriter.tag("/tbody");
        htmlWriter.line();
    }

    protected void renderRow(TableRow tableRow) {
        htmlWriter.line();
        htmlWriter.tag("tr", getAttributes(tableRow, "tr"));
        renderChildren(tableRow);
        htmlWriter.tag("/tr");
        htmlWriter.line();
    }

    protected void renderCell(TableCell tableCell) {
        string tagName = tableCell.isHeader() ? "th" : "td";
        htmlWriter.tag(tagName, getCellAttributes(tableCell, tagName));
        renderChildren(tableCell);
        htmlWriter.tag("/" + tagName);
    }

    private Map!(string, string) getAttributes(Node node, string tagName) {
        return context.extendAttributes(node, tagName, Collections.emptyMap!(string, string)());
    }

    private Map!(string, string) getCellAttributes(TableCell tableCell, string tagName) {
        if (tableCell.getAlignment() !is null) {
            return context.extendAttributes(tableCell, tagName, Collections.singletonMap("align", getAlignValue(tableCell.getAlignment())));
        } else {
            return context.extendAttributes(tableCell, tagName, Collections.emptyMap!(string, string)());
        }
    }

    private static string getAlignValue(TableCell.Alignment alignment) {
        switch (alignment) {
            case LEFT:
                return "left";
            case CENTER:
                return "center";
            case RIGHT:
                return "right";
        }
        throw new IllegalStateException("Unknown alignment: " + alignment);
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
