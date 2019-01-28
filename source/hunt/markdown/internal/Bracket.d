module hunt.markdown.internal.Bracket;

import hunt.markdown.node.Text;
import hunt.markdown.internal.Delimiter;

/**
 * Opening bracket for links (<code>[</code>) or images (<code>![</code>).
 */
class Bracket {

    public Text node;
    public int index;
    public bool _image;

    /**
     * Previous bracket.
     */
    public Bracket previous;

    /**
     * Previous delimiter (emphasis, etc) before this bracket.
     */
    public Delimiter previousDelimiter;

    /**
     * Whether this bracket is allowed to form a link/image (also known as "active").
     */
    public bool allowed = true;

    /**
     * Whether there is an unescaped bracket (opening or closing) anywhere after this opening bracket.
     */
    public bool bracketAfter = false;

    static public Bracket link(Text node, int index, Bracket previous, Delimiter previousDelimiter) {
        return new Bracket(node, index, previous, previousDelimiter, false);
    }

    static public Bracket image(Text node, int index, Bracket previous, Delimiter previousDelimiter) {
        return new Bracket(node, index, previous, previousDelimiter, true);
    }

    private this(Text node, int index, Bracket previous, Delimiter previousDelimiter, bool image) {
        this.node = node;
        this.index = index;
        this._image = image;
        this.previous = previous;
        this.previousDelimiter = previousDelimiter;
    }
}
