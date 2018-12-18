module hunt.markdown.node.Node;

import hunt.markdown.node.Visitor;

abstract class Node {

    private Node parent = null;
    private Node firstChild = null;
    private Node lastChild = null;
    private Node prev = null;
    private Node next = null;

    public abstract void accept(Visitor visitor);

    public Node getNext() {
        return next;
    }

    public Node getPrevious() {
        return prev;
    }

    public Node getFirstChild() {
        return firstChild;
    }

    public Node getLastChild() {
        return lastChild;
    }

    public Node getParent() {
        return parent;
    }

    protected void setParent(Node parent) {
        this.parent = parent;
    }

    public void appendChild(Node child) {
        child.unlink();
        child.setParent(this);
        if (this.lastChild !is null) {
            this.lastChild.next = child;
            child.prev = this.lastChild;
            this.lastChild = child;
        } else {
            this.firstChild = child;
            this.lastChild = child;
        }
    }

    public void prependChild(Node child) {
        child.unlink();
        child.setParent(this);
        if (this.firstChild !is null) {
            this.firstChild.prev = child;
            child.next = this.firstChild;
            this.firstChild = child;
        } else {
            this.firstChild = child;
            this.lastChild = child;
        }
    }

    public void unlink() {
        if (this.prev !is null) {
            this.prev.next = this.next;
        } else if (this.parent !is null) {
            this.parent.firstChild = this.next;
        }
        if (this.next !is null) {
            this.next.prev = this.prev;
        } else if (this.parent !is null) {
            this.parent.lastChild = this.prev;
        }
        this.parent = null;
        this.next = null;
        this.prev = null;
    }

    public void insertAfter(Node sibling) {
        sibling.unlink();
        sibling.next = this.next;
        if (sibling.next !is null) {
            sibling.next.prev = sibling;
        }
        sibling.prev = this;
        this.next = sibling;
        sibling.parent = this.parent;
        if (sibling.next is null) {
            sibling.parent.lastChild = sibling;
        }
    }

    public void insertBefore(Node sibling) {
        sibling.unlink();
        sibling.prev = this.prev;
        if (sibling.prev !is null) {
            sibling.prev.next = sibling;
        }
        sibling.next = this;
        this.prev = sibling;
        sibling.parent = this.parent;
        if (sibling.prev is null) {
            sibling.parent.firstChild = sibling;
        }
    }

    override public string toString() {
        return getClass().getSimpleName() + "{" + toStringAttributes() + "}";
    }

    protected string toStringAttributes() {
        return "";
    }
}
