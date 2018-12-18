module hunt.markdown.parser.block.BlockParserFactory;

import hunt.markdown.parser.block.ParserState;
import hunt.markdown.parser.block.BlockStart;
import hunt.markdown.parser.block.MatchedBlockParser;

/**
 * Parser factory for a block node for determining when a block starts.
 * <p>
 * Implementations should subclass {@link AbstractBlockParserFactory} instead of implementing this directly.
 */
public interface BlockParserFactory {

    BlockStart tryStart(ParserState state, MatchedBlockParser matchedBlockParser);

}
