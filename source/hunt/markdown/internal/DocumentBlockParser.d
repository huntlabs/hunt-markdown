module hunt.markdown.internal.DocumentBlockParser;

import hunt.markdown.node.Block;
import hunt.markdown.node.Document;
import hunt.markdown.parser.block.AbstractBlockParser;
import hunt.markdown.parser.block.BlockContinue;
import hunt.markdown.parser.block.ParserState;

class DocumentBlockParser : AbstractBlockParser {

    private Document document;

    this()
    {
        document = new Document();
    }

    override public bool isContainer() {
        return true;
    }

    override public bool canContain(Block block) {
        return true;
    }

    public Document getBlock() {
        return document;
    }

    public BlockContinue tryContinue(ParserState state) {
        return BlockContinue.atIndex(state.getIndex());
    }

    override public void addLine(string line) {
    }
}
