module hunt.markdown.parser.block.BlockParser;

import hunt.markdown.node.Block;
import hunt.markdown.parser.block.ParserState;
import hunt.markdown.parser.block.BlockContinue;
import hunt.markdown.parser.InlineParser;

/**
 * Parser for a specific block node.
 * <p>
 * Implementations should subclass {@link AbstractBlockParser} instead of implementing this directly.
 */
public interface BlockParser {

    /**
     * Return true if the block that is parsed is a container (contains other blocks), or false if it's a leaf.
     */
    bool isContainer();

    bool canContain(Block childBlock);

    Block getBlock();

    BlockContinue tryContinue(ParserState parserState);

    void addLine(string line);

    void closeBlock();

    void parseInlines(InlineParser inlineParser);

    int opCmp(BlockParser o);

}
