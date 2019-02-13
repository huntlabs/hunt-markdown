module hunt.markdown.internal.FencedCodeBlockParser;

import hunt.markdown.internal.util.Parsing;
import hunt.markdown.internal.util.Escaping;
import hunt.markdown.node.Block;
import hunt.markdown.node.FencedCodeBlock;
import hunt.markdown.parser.block.AbstractBlockParser;
import hunt.markdown.parser.block.BlockContinue;
import hunt.markdown.parser.block.ParserState;
import hunt.markdown.parser.block.AbstractBlockParserFactory;
import hunt.markdown.parser.block.BlockStart;
import hunt.markdown.parser.block.MatchedBlockParser;

import hunt.text;
import std.string;
import hunt.text.StringBuilder;

class FencedCodeBlockParser : AbstractBlockParser {

    private FencedCodeBlock block;

    private string firstLine;
    
    private StringBuilder otherLines;

    public this(char fenceChar, int fenceLength, int fenceIndent) {

        block = new FencedCodeBlock();
        otherLines = new StringBuilder();

        block.setFenceChar(fenceChar);
        block.setFenceLength(fenceLength);
        block.setFenceIndent(fenceIndent);
    }

    override public Block getBlock() {
        return block;
    }

    public BlockContinue tryContinue(ParserState state) {
        int nextNonSpace = state.getNextNonSpaceIndex();
        int newIndex = state.getIndex();
        string line = state.getLine();
        bool closing = state.getIndent() < Parsing.CODE_BLOCK_INDENT && isClosing(line, nextNonSpace);
        if (closing) {
            // closing fence - we're at end of line, so we can finalize now
            return BlockContinue.finished();
        } else {
            // skip optional spaces of fence indent
            int i = block.getFenceIndent();
            int length = cast(int)line.length;
            while (i > 0 && newIndex < length && line[newIndex] == ' ') {
                newIndex++;
                i--;
            }
        }
        return BlockContinue.atIndex(newIndex);
    }

    override public void addLine(string line) {
        if (firstLine is null) {
            firstLine = line;
        } else {
            otherLines.append(line);
            otherLines.append('\n');
        }
    }

    override public void closeBlock() {
        // first line becomes info string
        block.setInfo(Escaping.unescapeString(firstLine.strip()));
        block.setLiteral(otherLines.toString());
    }

    public static class Factory : AbstractBlockParserFactory {

        public BlockStart tryStart(ParserState state, MatchedBlockParser matchedBlockParser) {
            int indent = state.getIndent();
            if (indent >= Parsing.CODE_BLOCK_INDENT) {
                return BlockStart.none();
            }

            int nextNonSpace = state.getNextNonSpaceIndex();
            FencedCodeBlockParser blockParser = checkOpener(state.getLine(), nextNonSpace, indent);
            if (blockParser !is null) {
                return BlockStart.of(blockParser).atIndex(nextNonSpace + blockParser.block.getFenceLength());
            } else {
                return BlockStart.none();
            }
        }
    }

    // spec: A code fence is a sequence of at least three consecutive backtick characters (`) or tildes (~). (Tildes and
    // backticks cannot be mixed.)
    private static FencedCodeBlockParser checkOpener(string line, int index, int indent) {
        int backticks = 0;
        int tildes = 0;
        int length = cast(int)line.length;
        loop:
        for (int i = index; i < length; i++) {
            switch (line[i]) {
                case '`':
                    backticks++;
                    break;
                case '~':
                    tildes++;
                    break;
                default:
                    break loop;
            }
        }
        if (backticks >= 3 && tildes == 0) {
            // spec: The info string may not contain any backtick characters.
            if (Parsing.find('`', line, index + backticks) != -1) {
                return null;
            }
            return new FencedCodeBlockParser('`', backticks, indent);
        } else if (tildes >= 3 && backticks == 0) {
            if (Parsing.find('~', line, index + tildes) != -1) {
                return null;
            }
            return new FencedCodeBlockParser('~', tildes, indent);
        } else {
            return null;
        }
    }

    // spec: The content of the code block consists of all subsequent lines, until a closing code fence of the same type
    // as the code block began with (backticks or tildes), and with at least as many backticks or tildes as the opening
    // code fence.
    private bool isClosing(string line, int index) {
        char fenceChar = block.getFenceChar();
        int fenceLength = block.getFenceLength();
        int fences = Parsing.skip(fenceChar, line, index, cast(int)line.length) - index;
        if (fences < fenceLength) {
            return false;
        }
        // spec: The closing code fence [...] may be followed only by spaces, which are ignored.
        int after = Parsing.skipSpaceTab(line, index + fences, cast(int)line.length);
        return after == line.length;
    }
}
