module hunt.markdown.node.Paragraph;

import hunt.markdown.node.Block;
import hunt.markdown.node.Visitor;

class Paragraph : Block {

    override public void accept(Visitor visitor) {
        visitor.visit(this);
    }
}
