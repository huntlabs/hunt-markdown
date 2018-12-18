module hunt.markdown.node.CustomNode;

import hunt.markdown.node.Node;
import hunt.markdown.node.Visitor;

abstract class CustomNode : Node {
    override public void accept(Visitor visitor) {
        visitor.visit(this);
    }
}
