module hunt.markdown.node.HtmlBlock;

import hunt.markdown.node.Block;
import hunt.markdown.node.Visitor;

/**
 * HTML block
 */
class HtmlBlock : Block {

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
