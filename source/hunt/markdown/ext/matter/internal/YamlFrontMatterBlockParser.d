module hunt.markdown.ext.matter.internal.YamlFrontMatterBlockParser;

import hunt.markdown.ext.front.matter.YamlFrontMatterBlock;
import hunt.markdown.ext.front.matter.YamlFrontMatterNode;
import hunt.markdown.internal.DocumentBlockParser;
import hunt.markdown.node.Block;
import hunt.markdown.parser.InlineParser;
import hunt.markdown.parser.block.AbstractBlockParser;
import hunt.markdown.parser.block.AbstractBlockParserFactory;
import hunt.markdown.parser.block.BlockContinue;
import hunt.markdown.parser.block.ParserState;
import hunt.markdown.parser.block.BlockStart;
import hunt.markdown.parser.block.MatchedBlockParser;

import hunt.container.ArrayList;
import hunt.container.List;
import std.regex;

class YamlFrontMatterBlockParser : AbstractBlockParser {
    private __gshared Regex!char REGEX_METADATA = regex("^[ ]{0,3}([A-Za-z0-9_-]+):\\s*(.*)");
    private __gshared Regex!char REGEX_METADATA_LIST = regex("^[ ]+-\\s*(.*)");
    private __gshared Regex!char REGEX_METADATA_LITERAL = regex("^\\s*(.*)");
    private __gshared Regex!char REGEX_BEGIN = regex("^-{3}(\\s.*)?");
    private __gshared Regex!char REGEX_END = regex("^(-{3}|\\.{3})(\\s.*)?");

    private bool inLiteral;
    private string currentKey;
    private List!(string) currentValues;
    private YamlFrontMatterBlock block;

    public this() {
        inLiteral = false;
        currentKey = null;
        currentValues = new ArrayList!(string)();
        block = new YamlFrontMatterBlock();
    }

    override public Block getBlock() {
        return block;
    }

    override public void addLine(string line) {
    }

    override public BlockContinue tryContinue(ParserState parserState) {
        string line = parserState.getLine();

        if (REGEX_END.matcher(line).matches()) {
            if (currentKey !is null) {
                block.appendChild(new YamlFrontMatterNode(currentKey, currentValues));
            }
            return BlockContinue.finished();
        }

        Matcher matcher = REGEX_METADATA.matcher(line);
        if (matcher.matches()) {
            if (currentKey !is null) {
                block.appendChild(new YamlFrontMatterNode(currentKey, currentValues));
            }

            inLiteral = false;
            currentKey = matcher.group(1);
            currentValues = new ArrayList!(string)();
            if ("|" == matcher.group(2)) {
                inLiteral = true;
            } else if (!"" == matcher.group(2)) {
                currentValues.add(matcher.group(2));
            }

            return BlockContinue.atIndex(parserState.getIndex());
        } else {
            if (inLiteral) {
                matcher = REGEX_METADATA_LITERAL.matcher(line);
                if (matcher.matches()) {
                    if (currentValues.size() == 1) {
                        currentValues.set(0, currentValues.get(0) + "\n" + matcher.group(1).trim());
                    } else {
                        currentValues.add(matcher.group(1).trim());
                    }
                }
            } else {
                matcher = REGEX_METADATA_LIST.matcher(line);
                if (matcher.matches()) {
                    currentValues.add(matcher.group(1));
                }
            }

            return BlockContinue.atIndex(parserState.getIndex());
        }
    }

    override public void parseInlines(InlineParser inlineParser) {
    }

    public static class Factory : AbstractBlockParserFactory {
        override public BlockStart tryStart(ParserState state, MatchedBlockParser matchedBlockParser) {
            string line = state.getLine();
            BlockParser parentParser = matchedBlockParser.getMatchedBlockParser();
            // check whether this line is the first line of whole document or not
            if (cast(DocumentBlockParser)parentParser !is null && parentParser.getBlock().getFirstChild() is null &&
                    REGEX_BEGIN.matcher(line).matches()) {
                return BlockStart.of(new YamlFrontMatterBlockParser()).atIndex(state.getNextNonSpaceIndex());
            }

            return BlockStart.none();
        }
    }
}
