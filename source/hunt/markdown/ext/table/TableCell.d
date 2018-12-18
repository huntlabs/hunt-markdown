module hunt.markdown.ext.table.TableCell;

import hunt.markdown.node.CustomNode;

/**
 * Table cell of a {@link TableRow} containing inline nodes.
 */
class TableCell : CustomNode {

    private bool header;
    private Alignment alignment;

    /**
     * @return whether the cell is a header or not
     */
    public bool isHeader() {
        return header;
    }

    public void setHeader(bool header) {
        this.header = header;
    }

    /**
     * @return the cell alignment
     */
    public Alignment getAlignment() {
        return alignment;
    }

    public void setAlignment(Alignment alignment) {
        this.alignment = alignment;
    }

    /**
     * How the cell is aligned horizontally.
     */
    public enum Alignment {
        LEFT, CENTER, RIGHT
    }

}
