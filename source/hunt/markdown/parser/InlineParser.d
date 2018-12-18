module hunt.markdown.parser.InlineParser;

import hunt.markdown.node.Node;

/**
 * Parser for inline content (text, links, emphasized text, etc).
 */
public interface InlineParser {

    /**
     * @param input the content to parse as inline
     * @param node the node to append resulting nodes to (as children)
     */
    void parse(string input, Node node);
}
