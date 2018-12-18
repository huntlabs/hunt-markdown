module hunt.markdown.node.ListBlock;

import hunt.markdown.node.Block;
import hunt.markdown.node.Visitor;

abstract class ListBlock : Block {

    private bool tight;

    /**
     * @return whether this list is tight or loose
     */
    public bool isTight() {
        return tight;
    }

    public void setTight(bool tight) {
        this.tight = tight;
    }

}
