module hunt.markdown.internal.IndentedCodeBlockParser;

import hunt.markdown.internal.util.Parsing;
import hunt.markdown.node.Block;
import hunt.markdown.node.IndentedCodeBlock;
import hunt.markdown.node.Paragraph;
import hunt.markdown.parser.block.AbstractBlockParser;
import hunt.markdown.parser.block.BlockContinue;
import hunt.markdown.parser.block.ParserState;
import hunt.markdown.parser.block.BlockStart;
import hunt.markdown.parser.block.AbstractBlockParserFactory;
import hunt.markdown.parser.block.MatchedBlockParser;

import hunt.container.ArrayList;
import hunt.container.List;

class IndentedCodeBlockParser : AbstractBlockParser {

    private IndentedCodeBlock block = new IndentedCodeBlock();
    private List!(string) lines = new ArrayList!(string)();

    public Block getBlock() {
        return block;
    }

    public BlockContinue tryContinue(ParserState state) {
        if (state.getIndent() >= Parsing.CODE_BLOCK_INDENT) {
            return BlockContinue.atColumn(state.getColumn() + Parsing.CODE_BLOCK_INDENT);
        } else if (state.isBlank()) {
            return BlockContinue.atIndex(state.getNextNonSpaceIndex());
        } else {
            return BlockContinue.none();
        }
    }

    override public void addLine(string line) {
        lines.add(line);
    }

    override public void closeBlock() {
        int lastNonBlank = lines.size() - 1;
        while (lastNonBlank >= 0) {
            if (!Parsing.isBlank(lines.get(lastNonBlank))) {
                break;
            }
            lastNonBlank--;
        }

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < lastNonBlank + 1; i++) {
            sb.append(lines.get(i));
            sb.append('\n');
        }

        string literal = sb.toString();
        block.setLiteral(literal);
    }

    public static class Factory : AbstractBlockParserFactory {

        public BlockStart tryStart(ParserState state, MatchedBlockParser matchedBlockParser) {
            // An indented code block cannot interrupt a paragraph.
            if (state.getIndent() >= Parsing.CODE_BLOCK_INDENT && !state.isBlank() && cast(Paragraph)state.getActiveBlockParser().getBlock() is null) {
                return BlockStart.of(new IndentedCodeBlockParser()).atColumn(state.getColumn() + Parsing.CODE_BLOCK_INDENT);
            } else {
                return BlockStart.none();
            }
        }
    }
}

