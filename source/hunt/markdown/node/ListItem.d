module hunt.markdown.node.ListItem;

import hunt.markdown.node.Block;
import hunt.markdown.node.Visitor;

class ListItem : Block {

    override public void accept(Visitor visitor) {
        visitor.visit(this);
    }
}
