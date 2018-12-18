module hunt.markdown.node.CustomBlock;

import hunt.markdown.node.Block;
import hunt.markdown.node.Visitor;

abstract class CustomBlock : Block {

    override public void accept(Visitor visitor) {
        visitor.visit(this);
    }
}
