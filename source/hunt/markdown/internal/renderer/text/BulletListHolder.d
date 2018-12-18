module hunt.markdown.internal.renderer.text.BulletListHolder;

import hunt.markdown.node.BulletList;

class BulletListHolder : ListHolder {
    private char marker;

    public this(ListHolder parent, BulletList list) {
        super(parent);
        marker = list.getBulletMarker();
    }

    public char getMarker() {
        return marker;
    }
}
