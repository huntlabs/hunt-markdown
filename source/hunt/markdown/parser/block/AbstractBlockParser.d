module hunt.markdown.parser.block.AbstractBlockParser;

import hunt.markdown.node.Block;
import hunt.markdown.parser.InlineParser;
import hunt.markdown.parser.block.BlockParser;

abstract class AbstractBlockParser : BlockParser {

    public bool isContainer() {
        return false;
    }

    public bool canContain(Block childBlock) {
        return false;
    }

    override public void addLine(string line) {
    }

    void closeBlock() {
    }

    public void parseInlines(InlineParser inlineParser) {
    }
}
