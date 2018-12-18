module hunt.markdown.node.Block;

import hunt.markdown.node.Node;

abstract class Block : Node {

    override public Block getParent() {
        return cast(Block) super.getParent();
    }

    override protected void setParent(Node parent) {
        if (!(cast(Block)parent !is null)) {
            throw new IllegalArgumentException("Parent of block must also be block (can not be inline)");
        }
        super.setParent(parent);
    }
}
