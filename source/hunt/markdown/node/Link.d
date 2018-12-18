module hunt.markdown.node.Link;

import hunt.markdown.node.Node;
import hunt.markdown.node.Visitor;

/**
 * A link with a destination and an optional title; the link text is in child nodes.
 * <p>
 * Example for an inline link in a CommonMark document:
 * <pre><code>
 * [link](/uri "title")
 * </code></pre>
 * <p>
 * The corresponding Link node would look like this:
 * <ul>
 * <li>{@link #getDestination()} returns {@code "/uri"}
 * <li>{@link #getTitle()} returns {@code "title"}
 * <li>A {@link Text} child node with {@link Text#getLiteral() getLiteral} that returns {@code "link"}</li>
 * </ul>
 * <p>
 * Note that the text in the link can contain inline formatting, so it could also contain an {@link Image} or
 * {@link Emphasis}, etc.
 */
class Link : Node {

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
        return "destination=" + destination + ", title=" + title;
    }
}
