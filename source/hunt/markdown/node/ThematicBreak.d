module hunt.markdown.node.ThematicBreak;

import hunt.markdown.node.Block;
import hunt.markdown.node.Visitor;

class ThematicBreak : Block {

    override public void accept(Visitor visitor) {
        visitor.visit(this);
    }
}
