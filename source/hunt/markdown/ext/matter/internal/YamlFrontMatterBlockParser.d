module hunt.markdown.ext.matter.internal.YamlFrontMatterBlockParser;

import hunt.markdown.ext.matter.YamlFrontMatterBlock;
import hunt.markdown.ext.matter.YamlFrontMatterNode;
import hunt.markdown.internal.DocumentBlockParser;
import hunt.markdown.node.Block;
import hunt.markdown.parser.InlineParser;
import hunt.markdown.parser.block.AbstractBlockParser;
import hunt.markdown.parser.block.AbstractBlockParserFactory;
import hunt.markdown.parser.block.BlockContinue;
import hunt.markdown.parser.block.ParserState;
import hunt.markdown.parser.block.BlockStart;
import hunt.markdown.parser.block.MatchedBlockParser;
import hunt.markdown.parser.block.BlockParser;

import hunt.collection.ArrayList;
import hunt.collection.List;

import std.string;
import std.regex;
import hunt.util.Comparator;

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

    // /* override */ int opCmp(BlockParser o)
    // {
    //     auto cmp = compare(this.currentKey,(cast(YamlFrontMatterBlockParser)o).currentKey);
    //     if(cmp == 0)
    //     {
    //         cmp = compare(this.inLiteral,(cast(YamlFrontMatterBlockParser)o).inLiteral);
    //     }
    //     return cmp;
    // }


    override public Block getBlock() {
        return block;
    }

    override public void addLine(string line) {
    }

    public BlockContinue tryContinue(ParserState parserState) {
        string line = parserState.getLine();

        if (match(line, REGEX_END)) {
            if (currentKey !is null) {
                block.appendChild(new YamlFrontMatterNode(currentKey, currentValues));
            }
            return BlockContinue.finished();
        }

        auto matches = match(line, REGEX_METADATA);
        if (matches) {
            if (currentKey !is null) {
                block.appendChild(new YamlFrontMatterNode(currentKey, currentValues));
            }

            inLiteral = false;
            currentKey = matches.front[1];
            currentValues = new ArrayList!(string)();
            if ("|" == matches.front[2]) {
                inLiteral = true;
            } else if ("" != matches.front[2]) {
                currentValues.add(matches.front[2]);
            }

            return BlockContinue.atIndex(parserState.getIndex());
        } else {
            if (inLiteral) {
                matches = match(line, REGEX_METADATA_LITERAL);
                if (matches) {
                    if (currentValues.size() == 1) {
                        currentValues.set(0, currentValues.get(0) ~ "\n" ~ matches.front[1].strip());
                    } else {
                        currentValues.add(matches.front[1].strip());
                    }
                }
            } else {
                matches = match(line, REGEX_METADATA_LIST);
                if (matches) {
                    currentValues.add(matches.front[1]);
                }
            }

            return BlockContinue.atIndex(parserState.getIndex());
        }
    }

    override public void parseInlines(InlineParser inlineParser) {
    }

    public static class Factory : AbstractBlockParserFactory {
         public BlockStart tryStart(ParserState state, MatchedBlockParser matchedBlockParser) {
            string line = state.getLine();
            BlockParser parentParser = matchedBlockParser.getMatchedBlockParser();
            // check whether this line is the first line of whole document or not
            if (cast(DocumentBlockParser)parentParser !is null && parentParser.getBlock().getFirstChild() is null && match(line, REGEX_BEGIN)) {
                return BlockStart.of(new YamlFrontMatterBlockParser()).atIndex(state.getNextNonSpaceIndex());
            }

            return BlockStart.none();
        }
    }
}
