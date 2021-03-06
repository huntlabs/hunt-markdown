module hunt.markdown.ext.table.internal.TableHtmlNodeRenderer;

import hunt.collection.Collections;
import hunt.collection.Map;
import hunt.collection.HashMap;

import hunt.markdown.ext.table.TableBlock;
import hunt.markdown.ext.table.TableBody;
import hunt.markdown.ext.table.TableCell;
import hunt.markdown.ext.table.TableHead;
import hunt.markdown.ext.table.TableRow;
import hunt.markdown.ext.table.internal.TableNodeRenderer;
import hunt.markdown.node.Node;
import hunt.markdown.renderer.html.HtmlNodeRendererContext;
import hunt.markdown.renderer.html.HtmlWriter;

import std.conv : to;

class TableHtmlNodeRenderer : TableNodeRenderer {

    private HtmlWriter htmlWriter;
    private HtmlNodeRendererContext context;

    public this(HtmlNodeRendererContext context) {
        this.htmlWriter = context.getWriter();
        this.context = context;
    }

    override protected void renderBlock(TableBlock tableBlock) {
        htmlWriter.line();
        htmlWriter.tag("table", getAttributes(tableBlock, "table"));
        renderChildren(tableBlock);
        htmlWriter.tag("/table");
        htmlWriter.line();
    }

    override protected void renderHead(TableHead tableHead) {
        htmlWriter.line();
        htmlWriter.tag("thead", getAttributes(tableHead, "thead"));
        renderChildren(tableHead);
        htmlWriter.tag("/thead");
        htmlWriter.line();
    }

    override protected void renderBody(TableBody tableBody) {
        htmlWriter.line();
        htmlWriter.tag("tbody", getAttributes(tableBody, "tbody"));
        renderChildren(tableBody);
        htmlWriter.tag("/tbody");
        htmlWriter.line();
    }

    override protected void renderRow(TableRow tableRow) {
        htmlWriter.line();
        htmlWriter.tag("tr", getAttributes(tableRow, "tr"));
        renderChildren(tableRow);
        htmlWriter.tag("/tr");
        htmlWriter.line();
    }

    override protected void renderCell(TableCell tableCell) {
        string tagName = tableCell.isHeader() ? "th" : "td";
        htmlWriter.tag(tagName, getCellAttributes(tableCell, tagName));
        renderChildren(tableCell);
        htmlWriter.tag("/" ~ tagName);
    }

    private Map!(string, string) getAttributes(Node node, string tagName) {
        return context.extendAttributes(node, tagName, Collections.emptyMap!(string, string)());
    }

    private Map!(string, string) getCellAttributes(TableCell tableCell, string tagName)
    {
        auto attributes = new HashMap!(string, string);

        if (tableCell.getAlignment() != TableCell.Alignment.NONE) {
            attributes.put("align", getAlignValue(tableCell.getAlignment()));
        }

        return context.extendAttributes(tableCell, tagName, attributes);
    }

    private static string getAlignValue(TableCell.Alignment alignment) {
        switch (alignment) {
            case TableCell.Alignment.LEFT:
                return "left";
            case TableCell.Alignment.CENTER:
                return "center";
            case TableCell.Alignment.RIGHT:
                return "right";
            default:
                return null;
        }
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
