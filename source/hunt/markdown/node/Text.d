module hunt.markdown.node.Text;

import hunt.markdown.node.Node;
import hunt.markdown.node.Visitor;

class Text : Node {

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

    override protected string toStringAttributes() {
        return "literal=" + literal;
    }
}
