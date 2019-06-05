module hunt.markdown.ext.table.internal.TableNodeRenderer;

// import hunt.collection.Arrays;
import hunt.collection.HashSet;
import hunt.collection.Set;

import hunt.markdown.ext.table.TableBlock;
import hunt.markdown.ext.table.TableBody;
import hunt.markdown.ext.table.TableCell;
import hunt.markdown.ext.table.TableHead;
import hunt.markdown.ext.table.TableRow;
import hunt.markdown.node.Node;
import hunt.markdown.renderer.NodeRenderer;

abstract class TableNodeRenderer : NodeRenderer {

    // TypeInfo for D
    override public Set!TypeInfo_Class getNodeTypes() {
        return new HashSet!TypeInfo_Class([
                typeid(TableBlock),
                typeid(TableHead),
                typeid(TableBody),
                typeid(TableRow),
                typeid(TableCell)
        ]);
    }

    public void render(Node node) {
        if (cast(TableBlock)node !is null) {
            renderBlock(cast(TableBlock) node);
        } else if (cast(TableHead)node !is null ) {
            renderHead(cast(TableHead) node);
        } else if (cast(TableBody)node !is null) {
            renderBody(cast(TableBody) node);
        } else if (cast(TableRow)node !is null) {
            renderRow(cast(TableRow) node);
        } else if (cast(TableCell)node !is null) {
            renderCell(cast(TableCell) node);
        }
    }

    protected abstract void renderBlock(TableBlock node);

    protected abstract void renderHead(TableHead node);

    protected abstract void renderBody(TableBody node);

    protected abstract void renderRow(TableRow node);

    protected abstract void renderCell(TableCell node);
}
