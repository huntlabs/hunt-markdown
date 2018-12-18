module hunt.markdown.node.StrongEmphasis;

import hunt.markdown.node.Node;
import hunt.markdown.node.Delimited;
import hunt.markdown.node.Visitor;


class StrongEmphasis : Node, Delimited {

    private string delimiter;

    public this() {
    }

    public this(string delimiter) {
        this.delimiter = delimiter;
    }

    public void setDelimiter(string delimiter) {
        this.delimiter = delimiter;
    }

    override public string getOpeningDelimiter() {
        return delimiter;
    }

    override public string getClosingDelimiter() {
        return delimiter;
    }

    override public void accept(Visitor visitor) {
        visitor.visit(this);
    }
}
