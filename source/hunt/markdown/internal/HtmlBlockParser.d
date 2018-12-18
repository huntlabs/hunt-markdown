module hunt.markdown.internal.HtmlBlockParser;

import hunt.markdown.internal.util.Parsing;
import hunt.markdown.node.Block;
import hunt.markdown.node.HtmlBlock;
import hunt.markdown.node.Paragraph;
import hunt.markdown.parser.block.AbstractBlockParser;

class HtmlBlockParser : AbstractBlockParser {

    private static string[][] BLOCK_PATTERNS;
    
    static this()
    {
        BLOCK_PATTERNS = [
            [null, null],
            ["^<(?:script|pre|style)(?:\\s|>|$)", "</(?:script|pre|style)>"]
            ["^<!--", "-->"],
            ["^<[?]", "\\?>"],
            ["^<![A-Z]", ">"],
            ["^<!\\[CDATA\\[", "\\]\\]>"],
            ["^</?(?:" ~
                            "address|article|aside|" ~
                            "base|basefont|blockquote|body|" ~
                            "caption|center|col|colgroup|" ~
                            "dd|details|dialog|dir|div|dl|dt|" ~
                            "fieldset|figcaption|figure|footer|form|frame|frameset|" ~
                            "h1|h2|h3|h4|h5|h6|head|header|hr|html|" ~
                            "iframe|" ~
                            "legend|li|link|" ~
                            "main|menu|menuitem|meta|" ~
                            "nav|noframes|" ~
                            "ol|optgroup|option|" ~
                            "p|param|" ~
                            "section|source|summary|" ~
                            "table|tbody|td|tfoot|th|thead|title|tr|track|" ~
                            "ul" ~
                            ")(?:\\s|[/]?[>]|$)"],
            ["^(?:" + Parsing.OPENTAG + '|' + Parsing.CLOSETAG + ")\\s*$", null]
        ];
    }

    private HtmlBlock block = new HtmlBlock();
    private Pattern closingPattern;

    private bool finished = false;
    private BlockContent content = new BlockContent();

    private this(Pattern closingPattern) {
        this.closingPattern = closingPattern;
    }

    override public Block getBlock() {
        return block;
    }

    override public BlockContinue tryContinue(ParserState state) {
        if (finished) {
            return BlockContinue.none();
        }

        // Blank line ends type 6 and type 7 blocks
        if (state.isBlank() && closingPattern is null) {
            return BlockContinue.none();
        } else {
            return BlockContinue.atIndex(state.getIndex());
        }
    }

    override public void addLine(string line) {
        content.add(line);

        if (closingPattern !is null && closingPattern.matcher(line).find()) {
            finished = true;
        }
    }

    override public void closeBlock() {
        block.setLiteral(content.getString());
        content = null;
    }

    public static class Factory : AbstractBlockParserFactory {

        override public BlockStart tryStart(ParserState state, MatchedBlockParser matchedBlockParser) {
            int nextNonSpace = state.getNextNonSpaceIndex();
            string line = state.getLine();

            if (state.getIndent() < 4 && line[nextNonSpace] == '<') {
                for (int blockType = 1; blockType <= 7; blockType++) {
                    // Type 7 can not interrupt a paragraph
                    if (blockType == 7 && cast(Paragraph)matchedBlockParser.getMatchedBlockParser().getBlock() !is null) {
                        continue;
                    }
                    Pattern opener = BLOCK_PATTERNS[blockType][0];
                    Pattern closer = BLOCK_PATTERNS[blockType][1];
                    bool matches = opener.matcher(line.subSequence(nextNonSpace, line.length())).find();
                    if (matches) {
                        return BlockStart.of(new HtmlBlockParser(closer)).atIndex(state.getIndex());
                    }
                }
            }
            return BlockStart.none();
        }
    }
}
