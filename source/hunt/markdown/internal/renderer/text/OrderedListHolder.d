module hunt.markdown.internal.renderer.text.OrderedListHolder;

import hunt.markdown.node.OrderedList;

class OrderedListHolder : ListHolder {
    private char delimiter;
    private int counter;

    public this(ListHolder parent, OrderedList list) {
        super(parent);
        delimiter = list.getDelimiter();
        counter = list.getStartNumber();
    }

    public char getDelimiter() {
        return delimiter;
    }

    public int getCounter() {
        return counter;
    }

    public void increaseCounter() {
        counter++;
    }
}
