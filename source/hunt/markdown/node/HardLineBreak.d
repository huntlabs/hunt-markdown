module hunt.markdown.node.HardLineBreak;

import hunt.markdown.node.Node;
import hunt.markdown.node.Visitor;

class HardLineBreak : Node {

    override public void accept(Visitor visitor) {
        visitor.visit(this);
    }
}
