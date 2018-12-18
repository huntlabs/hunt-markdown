module hunt.markdown.internal.Delimiter;

import hunt.markdown.node.Text;
import hunt.markdown.parser.delimiter.DelimiterRun;

/**
 * Delimiter (emphasis, strong emphasis or custom emphasis).
 */
class Delimiter : DelimiterRun {

    public Text node;
    public char delimiterChar;

    /**
     * Can open emphasis, see spec.
     */
    public bool canOpen;

    /**
     * Can close emphasis, see spec.
     */
    public bool canClose;

    public Delimiter previous;
    public Delimiter next;

    public int length = 1;
    public int originalLength = 1;

    public this(Text node, char delimiterChar, bool canOpen, bool canClose, Delimiter previous) {
        this.node = node;
        this.delimiterChar = delimiterChar;
        this.canOpen = canOpen;
        this.canClose = canClose;
        this.previous = previous;
    }

    override public bool canOpen() {
        return canOpen;
    }

    override public bool canClose() {
        return canClose;
    }

    override public int length() {
        return length;
    }

    override public int originalLength() {
        return originalLength;
    }
}
