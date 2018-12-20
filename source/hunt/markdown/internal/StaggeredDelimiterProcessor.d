module hunt.markdown.internal.StaggeredDelimiterProcessor;

import hunt.markdown.node.Text;
import hunt.markdown.parser.delimiter.DelimiterProcessor;
import hunt.markdown.parser.delimiter.DelimiterRun;

import hunt.container.LinkedList;
// import hunt.container.ListIterator;

/**
 * An implementation of DelimiterProcessor that dispatches all calls to two or more other DelimiterProcessors
 * depending on the length of the delimiter run. All child DelimiterProcessors must have different minimum
 * lengths. A given delimiter run is dispatched to the child with the largest acceptable minimum length. If no
 * child is applicable, the one with the largest minimum length is chosen.
 */
class StaggeredDelimiterProcessor : DelimiterProcessor {

    private char delim;
    private int minLength = 0;
    private LinkedList!(DelimiterProcessor) processors; // in reverse getMinLength order

    this(char delim) {
        processors = new LinkedList!(DelimiterProcessor)();
        this.delim = delim;
    }


    override public char getOpeningCharacter() {
        return delim;
    }

    override public char getClosingCharacter() {
        return delim;
    }

    override public int getMinLength() {
        return minLength;
    }

    void add(DelimiterProcessor dp) {
        int len = dp.getMinLength();
        ListIterator!(DelimiterProcessor) it = processors.listIterator();
        bool added = false;
        while (it.hasNext()) {
            DelimiterProcessor p = it.next();
            int pLen = p.getMinLength();
            if (len > pLen) {
                it.previous();
                it.add(dp);
                added = true;
                break;
            } else if (len == pLen) {
                throw new IllegalArgumentException("Cannot add two delimiter processors for char '" ~ delim ~ "' and minimum length " ~ len);
            }
        }
        if (!added) {
            processors.add(dp);
            this.minLength = len;
        }
    }

    private DelimiterProcessor findProcessor(int len) {
        foreach (DelimiterProcessor p ; processors) {
            if (p.getMinLength() <= len) {
                return p;
            }
        }
        return processors.getFirst();
    }

    override public int getDelimiterUse(DelimiterRun opener, DelimiterRun closer) {
        return findProcessor(opener.length()).getDelimiterUse(opener, closer);
    }

    override public void process(Text opener, Text closer, int delimiterUse) {
        findProcessor(delimiterUse).process(opener, closer, delimiterUse);
    }
}
