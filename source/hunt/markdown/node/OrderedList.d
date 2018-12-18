module hunt.markdown.node.OrderedList;

import hunt.markdown.node.ListBlock;
import hunt.markdown.node.Visitor;

class OrderedList : ListBlock {

    private int startNumber;
    private char delimiter;

    override public void accept(Visitor visitor) {
        visitor.visit(this);
    }

    public int getStartNumber() {
        return startNumber;
    }

    public void setStartNumber(int startNumber) {
        this.startNumber = startNumber;
    }

    public char getDelimiter() {
        return delimiter;
    }

    public void setDelimiter(char delimiter) {
        this.delimiter = delimiter;
    }

}
