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
    public bool _canOpen;

    /**
     * Can close emphasis, see spec.
     */
    public bool _canClose;

    public Delimiter previous;
    public Delimiter next;

    public int _length = 1;
    public int _originalLength = 1;

    public this(Text node, char delimiterChar, bool canOpen, bool canClose, Delimiter previous) {
        this.node = node;
        this.delimiterChar = delimiterChar;
        this._canOpen = canOpen;
        this._canClose = canClose;
        this.previous = previous;
    }

    public bool canOpen() {
        return _canOpen;
    }

    public bool canClose() {
        return _canClose;
    }

    @property public int length() {
        return _length;
    }

    public void setLength(int len) {
        _length = len;
    }

    @property public int originalLength() {
        return _originalLength;
    }

     public void setOriginalLength(int len) {
        _originalLength = len;
    }
}
