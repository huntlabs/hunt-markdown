module hunt.markdown.node.HtmlInline;


import hunt.markdown.node.Node;
import hunt.markdown.node.Visitor;

/**
 * Inline HTML element.
 */
class HtmlInline : Node {

    private string literal;

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
