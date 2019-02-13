module hunt.markdown.parser.block.AbstractBlockParser;

import hunt.markdown.node.Block;
import hunt.markdown.parser.InlineParser;
import hunt.markdown.parser.block.BlockParser;
import hunt.util.Comparator;

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

    override Block getBlock(){
        return null;
    }

    public void parseInlines(InlineParser inlineParser) {
    }

    override int opCmp(BlockParser o)
    {
        auto cmp = compare(getBlock(),o.getBlock());
        import hunt.logging;
        logDebug("------223---");
        return cmp;
    }
}
