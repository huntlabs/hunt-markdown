module hunt.markdown.ext.gfm.strikethrough.internal.StrikethroughDelimiterProcessor;

import hunt.markdown.ext.gfm.strikethrough.Strikethrough;
import hunt.markdown.node.Node;
import hunt.markdown.node.Text;
import hunt.markdown.parser.delimiter.DelimiterProcessor;
import hunt.markdown.parser.delimiter.DelimiterRun;

class StrikethroughDelimiterProcessor : DelimiterProcessor {

    override public char getOpeningCharacter() {
        return '~';
    }

    override public char getClosingCharacter() {
        return '~';
    }

    override public int getMinLength() {
        return 2;
    }

    override public int getDelimiterUse(DelimiterRun opener, DelimiterRun closer) {
        if (opener.length() >= 2 && closer.length() >= 2) {
            // Use exactly two delimiters even if we have more, and don't care about internal openers/closers.
            return 2;
        } else {
            return 0;
        }
    }

    override public void process(Text opener, Text closer, int delimiterCount) {
        // Wrap nodes between delimiters in strikethrough.
        Node strikethrough = new Strikethrough();

        Node tmp = opener.getNext();
        while (tmp !is null && tmp != closer) {
            Node next = tmp.getNext();
            strikethrough.appendChild(tmp);
            tmp = next;
        }

        opener.insertAfter(strikethrough);
    }
}
