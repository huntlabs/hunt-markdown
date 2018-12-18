module hunt.markdown.ext.ins.Ins;

import hunt.markdown.node.CustomNode;
import hunt.markdown.node.Delimited;

/**
 * An ins node containing text and other inline nodes as children.
 */
class Ins : CustomNode, Delimited {

    private enum string DELIMITER = "++";

    override public string getOpeningDelimiter() {
        return DELIMITER;
    }

    override public string getClosingDelimiter() {
        return DELIMITER;
    }
}
