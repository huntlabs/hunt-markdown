module hunt.markdown.internal.HeadingParser;

import hunt.markdown.internal.util.Parsing;
import hunt.markdown.node.Block;
import hunt.markdown.node.Heading;
import hunt.markdown.parser.InlineParser;
import hunt.markdown.parser.block.AbstractBlockParser;

class HeadingParser : AbstractBlockParser {

    private Heading block = new Heading();
    private string content;

    public this(int level, string content) {
        block.setLevel(level);
        this.content = content;
    }

    override public Block getBlock() {
        return block;
    }

    override public BlockContinue tryContinue(ParserState parserState) {
        // In both ATX and Setext headings, once we have the heading markup, there's nothing more to parse.
        return BlockContinue.none();
    }

    override public void parseInlines(InlineParser inlineParser) {
        inlineParser.parse(content, block);
    }

    public static class Factory : AbstractBlockParserFactory {

        override public BlockStart tryStart(ParserState state, MatchedBlockParser matchedBlockParser) {
            if (state.getIndent() >= Parsing.CODE_BLOCK_INDENT) {
                return BlockStart.none();
            }

            string line = state.getLine();
            int nextNonSpace = state.getNextNonSpaceIndex();
            HeadingParser atxHeading = getAtxHeading(line, nextNonSpace);
            if (atxHeading !is null) {
                return BlockStart.of(atxHeading).atIndex(line.length());
            }

            int setextHeadingLevel = getSetextHeadingLevel(line, nextNonSpace);
            if (setextHeadingLevel > 0) {
                string paragraph = matchedBlockParser.getParagraphContent();
                if (paragraph !is null) {
                    string content = paragraph.toString();
                    return BlockStart.of(new HeadingParser(setextHeadingLevel, content))
                            .atIndex(line.length())
                            .replaceActiveBlockParser();
                }
            }

            return BlockStart.none();
        }
    }

    // spec: An ATX heading consists of a string of characters, parsed as inline content, between an opening sequence of
    // 1–6 unescaped # characters and an optional closing sequence of any number of unescaped # characters. The opening
    // sequence of # characters must be followed by a space or by the end of line. The optional closing sequence of #s
    // must be preceded by a space and may be followed by spaces only.
    private static HeadingParser getAtxHeading(string line, int index) {
        int level = Parsing.skip('#', line, index, line.length()) - index;

        if (level == 0 || level > 6) {
            return null;
        }

        int start = index + level;
        if (start >= line.length()) {
            // End of line after markers is an empty heading
            return new HeadingParser(level, "");
        }

        char next = line[start];
        if (!(next == ' ' || next == '\t')) {
            return null;
        }

        int beforeSpace = Parsing.skipSpaceTabBackwards(line, line.length() - 1, start);
        int beforeHash = Parsing.skipBackwards('#', line, beforeSpace, start);
        int beforeTrailer = Parsing.skipSpaceTabBackwards(line, beforeHash, start);
        if (beforeTrailer != beforeHash) {
            return new HeadingParser(level, line.subSequence(start, beforeTrailer + 1).toString());
        } else {
            return new HeadingParser(level, line.subSequence(start, beforeSpace + 1).toString());
        }
    }

    // spec: A setext heading underline is a sequence of = characters or a sequence of - characters, with no more than
    // 3 spaces indentation and any number of trailing spaces.
    private static int getSetextHeadingLevel(string line, int index) {
        switch (line[index]) {
            case '=':
                if (isSetextHeadingRest(line, index + 1, '=')) {
                    return 1;
                }
            case '-':
                if (isSetextHeadingRest(line, index + 1, '-')) {
                    return 2;
                }
        }
        return 0;
    }

    private static bool isSetextHeadingRest(string line, int index, char marker) {
        int afterMarker = Parsing.skip(marker, line, index, line.length());
        int afterSpace = Parsing.skipSpaceTab(line, afterMarker, line.length());
        return afterSpace >= line.length();
    }
}
