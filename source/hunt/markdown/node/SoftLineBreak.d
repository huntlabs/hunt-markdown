module hunt.markdown.node.SoftLineBreak;

import hunt.markdown.node.Node;
import hunt.markdown.node.Visitor;

class SoftLineBreak : Node {

    override public void accept(Visitor visitor) {
        visitor.visit(this);
    }
}
