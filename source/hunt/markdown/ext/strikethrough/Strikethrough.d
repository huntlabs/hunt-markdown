module hunt.markdown.ext.gfm.strikethrough.Strikethrough;

import hunt.markdown.node.CustomNode;
import hunt.markdown.node.Delimited;

/**
 * A strikethrough node containing text and other inline nodes nodes as children.
 */
class Strikethrough : CustomNode, Delimited {

    private __gshared string  DELIMITER = "~~";

    override public string getOpeningDelimiter() {
        return DELIMITER;
    }

    override public string getClosingDelimiter() {
        return DELIMITER;
    }
}
