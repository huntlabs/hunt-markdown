module hunt.markdown.node.Document;

import hunt.markdown.node.Block;
import hunt.markdown.node.Visitor;

class Document : Block {

    override public void accept(Visitor visitor) {
        visitor.visit(this);
    }
}
