module hunt.markdown.node.BlockQuote;

import hunt.markdown.node.Block;
import hunt.markdown.node.Visitor;

class BlockQuote : Block {

    override public void accept(Visitor visitor) {
        visitor.visit(this);
    }
}
