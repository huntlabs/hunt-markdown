module hunt.markdown.node.Image;

import hunt.markdown.node.Node;
import hunt.markdown.node.Visitor;

class Image : Node {

    private string destination;
    private string title;

    public this() {
    }

    public this(string destination, string title) {
        this.destination = destination;
        this.title = title;
    }

    override public void accept(Visitor visitor) {
        visitor.visit(this);
    }

    public string getDestination() {
        return destination;
    }

    public void setDestination(string destination) {
        this.destination = destination;
    }

    public string getTitle() {
        return title;
    }

    public void setTitle(string title) {
        this.title = title;
    }

    override protected string toStringAttributes() {
        return "destination=" ~ destination ~ ", title=" ~ title;
    }
}
