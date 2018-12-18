module hunt.markdown.node.IndentedCodeBlock;

import hunt.markdown.node.Block;
import hunt.markdown.node.Visitor;

class IndentedCodeBlock : Block {

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
