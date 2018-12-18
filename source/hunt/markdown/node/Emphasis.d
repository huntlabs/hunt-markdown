module hunt.markdown.node.Emphasis;

import hunt.markdown.node.Node;
import hunt.markdown.node.Visitor;
import hunt.markdown.node.Delimited;

class Emphasis : Node, Delimited {

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
