module hunt.markdown.internal.ThematicBreakParser;

import hunt.markdown.node.Block;
import hunt.markdown.node.ThematicBreak;
import hunt.markdown.parser.block.AbstractBlockParser;
import hunt.markdown.parser.block.BlockContinue;
import hunt.markdown.parser.block.ParserState;
import hunt.markdown.parser.block.BlockStart;
import hunt.markdown.parser.block.MatchedBlockParser;
import hunt.markdown.parser.block.AbstractBlockParserFactory;

class ThematicBreakParser : AbstractBlockParser {

    private ThematicBreak block;

    this()
    {
        block = new ThematicBreak();
    }

    public Block getBlock() {
        return block;
    }

    public BlockContinue tryContinue(ParserState state) {
        // a horizontal rule can never container > 1 line, so fail to match
        return BlockContinue.none();
    }

    public static class Factory : AbstractBlockParserFactory {

        public BlockStart tryStart(ParserState state, MatchedBlockParser matchedBlockParser) {
            if (state.getIndent() >= 4) {
                return BlockStart.none();
            }
            int nextNonSpace = state.getNextNonSpaceIndex();
            string line = state.getLine();
            if (isThematicBreak(line, nextNonSpace)) {
                return BlockStart.of(new ThematicBreakParser()).atIndex(cast(int)(line.length));
            } else {
                return BlockStart.none();
            }
        }
    }

    // spec: A line consisting of 0-3 spaces of indentation, followed by a sequence of three or more matching -, _, or *
    // characters, each followed optionally by any number of spaces, forms a thematic break.
    private static bool isThematicBreak(string line, int index) {
        int dashes = 0;
        int underscores = 0;
        int asterisks = 0;
        int length =cast(int)(line.length);
        for (int i = index; i < length; i++) {
            switch (line[i]) {
                case '-':
                    dashes++;
                    break;
                case '_':
                    underscores++;
                    break;
                case '*':
                    asterisks++;
                    break;
                case ' ':
                case '\t':
                    // Allowed, even between markers
                    break;
                default:
                    return false;
            }
        }

        return ((dashes >= 3 && underscores == 0 && asterisks == 0) ||
                (underscores >= 3 && dashes == 0 && asterisks == 0) ||
                (asterisks >= 3 && dashes == 0 && underscores == 0));
    }
}
