module hunt.markdown.node.Code;

import hunt.markdown.node.Node;
import hunt.markdown.node.Visitor;

class Code : Node {

    private string literal;

    public this() {
    }

    public this(string literal) {
        this.literal = literal;
    }

    override public void accept(Visitor visitor) {
        visitor.visit(this);
    }

    public string getLiteral() {
        return literal;
    }

    public void setLiteral(string literal) {
        this.literal = literal;
    }
}
