module hunt.markdown.node.Heading;

import hunt.markdown.node.Block;
import hunt.markdown.node.Visitor;

class Heading : Block {

    private int level;

    override public void accept(Visitor visitor) {
        visitor.visit(this);
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }
}
