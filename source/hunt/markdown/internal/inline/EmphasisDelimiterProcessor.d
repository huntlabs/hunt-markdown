module hunt.markdown.internal.inline.EmphasisDelimiterProcessor;

import hunt.markdown.node.Emphasis;
import hunt.markdown.node.Node;
import hunt.markdown.node.StrongEmphasis;
import hunt.markdown.node.Text;
import hunt.markdown.parser.delimiter.DelimiterProcessor;
import hunt.markdown.parser.delimiter.DelimiterRun;

abstract class EmphasisDelimiterProcessor : DelimiterProcessor {

    private char delimiterChar;

    protected this(char delimiterChar) {
        this.delimiterChar = delimiterChar;
    }

    override public char getOpeningCharacter() {
        return delimiterChar;
    }

    override public char getClosingCharacter() {
        return delimiterChar;
    }

    override public int getMinLength() {
        return 1;
    }

    override public int getDelimiterUse(DelimiterRun opener, DelimiterRun closer) {
        // "multiple of 3" rule for internal delimiter runs
        if ((opener.canClose() || closer.canOpen()) && (opener.originalLength() + closer.originalLength()) % 3 == 0) {
            return 0;
        }
        // calculate actual number of delimiters used from this closer
        if (opener.length() >= 2 && closer.length() >= 2) {
            return 2;
        } else {
            return 1;
        }
    }

    override public void process(Text opener, Text closer, int delimiterUse) {
        string singleDelimiter = String.valueOf(getOpeningCharacter());
        Node emphasis = delimiterUse == 1
                ? new Emphasis(singleDelimiter)
                : new StrongEmphasis(singleDelimiter ~ singleDelimiter);

        Node tmp = opener.getNext();
        while (tmp !is null && tmp != closer) {
            Node next = tmp.getNext();
            emphasis.appendChild(tmp);
            tmp = next;
        }

        opener.insertAfter(emphasis);
    }
}
