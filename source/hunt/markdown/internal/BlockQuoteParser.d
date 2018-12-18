module hunt.markdown.internal.BlockQuoteParser;

import hunt.markdown.internal.util.Parsing;
import hunt.markdown.node.Block;
import hunt.markdown.node.BlockQuote;
import hunt.markdown.parser.block.AbstractBlockParser;

class BlockQuoteParser : AbstractBlockParser {

    private BlockQuote block = new BlockQuote();

    override public bool isContainer() {
        return true;
    }

    override public bool canContain(Block block) {
        return true;
    }

    override public BlockQuote getBlock() {
        return block;
    }

    override public BlockContinue tryContinue(ParserState state) {
        int nextNonSpace = state.getNextNonSpaceIndex();
        if (isMarker(state, nextNonSpace)) {
            int newColumn = state.getColumn() + state.getIndent() + 1;
            // optional following space or tab
            if (Parsing.isSpaceOrTab(state.getLine(), nextNonSpace + 1)) {
                newColumn++;
            }
            return BlockContinue.atColumn(newColumn);
        } else {
            return BlockContinue.none();
        }
    }

    private static bool isMarker(ParserState state, int index) {
        string line = state.getLine();
        return state.getIndent() < Parsing.CODE_BLOCK_INDENT && index < line.length() && line[index] == '>';
    }

    public static class Factory : AbstractBlockParserFactory {
        public BlockStart tryStart(ParserState state, MatchedBlockParser matchedBlockParser) {
            int nextNonSpace = state.getNextNonSpaceIndex();
            if (isMarker(state, nextNonSpace)) {
                int newColumn = state.getColumn() + state.getIndent() + 1;
                // optional following space or tab
                if (Parsing.isSpaceOrTab(state.getLine(), nextNonSpace + 1)) {
                    newColumn++;
                }
                return BlockStart.of(new BlockQuoteParser()).atColumn(newColumn);
            } else {
                return BlockStart.none();
            }
        }
    }
}
