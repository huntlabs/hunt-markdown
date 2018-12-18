module hunt.markdown.node.BulletList;

import hunt.markdown.node.ListBlock;
import hunt.markdown.node.Visitor;

class BulletList : ListBlock {

    private char bulletMarker;

    override public void accept(Visitor visitor) {
        visitor.visit(this);
    }

    public char getBulletMarker() {
        return bulletMarker;
    }

    public void setBulletMarker(char bulletMarker) {
        this.bulletMarker = bulletMarker;
    }

}
