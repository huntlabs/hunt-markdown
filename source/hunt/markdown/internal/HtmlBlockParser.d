module hunt.markdown.internal.HtmlBlockParser;

import hunt.markdown.internal.util.Parsing;
import hunt.markdown.internal.BlockContent;
import hunt.markdown.node.Block;
import hunt.markdown.node.HtmlBlock;
import hunt.markdown.node.Paragraph;
import hunt.markdown.parser.block.AbstractBlockParser;
import hunt.markdown.parser.block.BlockContinue;
import hunt.markdown.parser.block.ParserState;
import hunt.markdown.parser.block.BlockStart;
import hunt.markdown.parser.block.AbstractBlockParserFactory;
import hunt.markdown.parser.block.MatchedBlockParser;

import std.regex;

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

    private HtmlBlock block;
    private Regex!char closingPattern;

    private bool finished = false;
    private BlockContent content;

    private this(Regex!char closingPattern) {
        block = new HtmlBlock();
        content = new BlockContent();
        this.closingPattern = closingPattern;
    }

    public Block getBlock() {
        return block;
    }

    public BlockContinue tryContinue(ParserState state) {
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

        public BlockStart tryStart(ParserState state, MatchedBlockParser matchedBlockParser) {
            int nextNonSpace = state.getNextNonSpaceIndex();
            string line = state.getLine();

            if (state.getIndent() < 4 && line[nextNonSpace] == '<') {
                for (int blockType = 1; blockType <= 7; blockType++) {
                    // Type 7 can not interrupt a paragraph
                    if (blockType == 7 && cast(Paragraph)matchedBlockParser.getMatchedBlockParser().getBlock() !is null) {
                        continue;
                    }
                    Regex!char opener = BLOCK_PATTERNS[blockType][0];
                    Regex!char closer = BLOCK_PATTERNS[blockType][1];
                    bool matches = opener.matcher(line.subSequence(nextNonSpace, cast(int)line.length)).find();
                    if (matches) {
                        return BlockStart.of(new HtmlBlockParser(closer)).atIndex(state.getIndex());
                    }
                }
            }
            return BlockStart.none();
        }
    }
}
