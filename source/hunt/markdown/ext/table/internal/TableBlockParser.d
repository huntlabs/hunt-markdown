module hunt.markdown.ext.table.internal.TableBlockParser;

import hunt.markdown.ext.table;
import hunt.markdown.node.Block;
import hunt.markdown.node.Node;
import hunt.markdown.parser.InlineParser;
import hunt.markdown.parser.block.AbstractBlockParser;
import hunt.markdown.parser.block.BlockContinue;
import hunt.markdown.parser.block.ParserState;
import hunt.markdown.parser.block.AbstractBlockParserFactory;
import hunt.markdown.parser.block.BlockStart;
import hunt.markdown.parser.block.MatchedBlockParser;

import hunt.collection.ArrayList;
import hunt.collection.List;

import std.string;
import std.regex;

import hunt.text;

class TableBlockParser : AbstractBlockParser {

    private static string COL = "\\s*:?-{1,}:?\\s*";
    private static Regex!char TABLE_HEADER_SEPARATOR;

    private TableBlock block;
    private List!(string) rowLines;

    private bool nextIsSeparatorLine = true;
    private string separatorLine = "";

    static this()
    {
        TABLE_HEADER_SEPARATOR = regex(
            // For single column, require at least one pipe, otherwise it's ambiguous with setext headers
            "\\|" ~ COL ~ "\\|?\\s*" ~ "|" ~
            COL ~ "\\|\\s*" ~ "|" ~
            "\\|?" ~ "(?:" ~ COL ~ "\\|)+" ~ COL ~ "\\|?\\s*");
    }

    private this(string headerLine) {
        block = new TableBlock();
        rowLines = new ArrayList!(string)();

        rowLines.add(headerLine);
    }

    public Block getBlock() {
        return block;
    }

    public BlockContinue tryContinue(ParserState state) {
        import std.algorithm;

        if (state.getLine().findSplit("|").length > 0) {
            return BlockContinue.atIndex(state.getIndex());
        } else {
            return BlockContinue.none();
        }
    }

    override public void addLine(string line) {
        if (nextIsSeparatorLine) {
            nextIsSeparatorLine = false;
            separatorLine = line;
        } else {
            rowLines.add(line);
        }
    }

    override public void parseInlines(InlineParser inlineParser) {
        Node section = new TableHead();
        block.appendChild(section);

        List!(TableCell.Alignment) alignments = parseAlignment(separatorLine);

        int headerColumns = -1;
        bool header = true;
        foreach (string rowLine ; rowLines) {
            List!(string) cells = split(rowLine);
            TableRow tableRow = new TableRow();

            if (headerColumns == -1) {
                headerColumns = cells.size();
            }

            // Body can not have more columns than head
            for (int i = 0; i < headerColumns; i++) {
                string cell = i < cells.size() ? cells.get(i) : "";
                TableCell.Alignment alignment = alignments.get(i);
                TableCell tableCell = new TableCell();
                tableCell.setHeader(header);
                tableCell.setAlignment(alignment);
                inlineParser.parse(cell.strip(), tableCell);
                tableRow.appendChild(tableCell);
            }

            section.appendChild(tableRow);

            if (header) {
                // Format allows only one row in head
                header = false;
                section = new TableBody();
                block.appendChild(section);
            }
        }
    }

    private static List!(TableCell.Alignment) parseAlignment(string separatorLine) {
        List!(string) parts = split(separatorLine);
        List!(TableCell.Alignment) alignments = new ArrayList!(TableCell.Alignment)();
        foreach (string part ; parts) {
            string trimmed = part.strip();
            bool left = trimmed.startsWith(":");
            bool right = trimmed.endsWith(":");
            TableCell.Alignment alignment = getAlignment(left, right);
            alignments.add(alignment);
        }
        return alignments;
    }

    private static List!(string) split(string input) {
        string line = input.strip();
        if (line.startsWith("|")) {
            line = line.substring(1);
        }
        List!(string) cells = new ArrayList!(string)();
        StringBuilder sb = new StringBuilder();
        bool escape = false;
        for (int i = 0; i < line.length; i++) {
            char c = line[i];
            if (escape) {
                escape = false;
                sb.append(c);
            } else {
                switch (c) {
                    case '\\':
                        escape = true;
                        // Removing the escaping '\' is handled by the inline parser later, so add it to cell
                        sb.append(c);
                        break;
                    case '|':
                        cells.add(sb.toString());
                        sb.setLength(0);
                        break;
                    default:
                        sb.append(c);
                }
            }
        }
        if (sb.length > 0) {
            cells.add(sb.toString());
        }
        return cells;
    }

    private static TableCell.Alignment getAlignment(bool left, bool right) {
        if (left && right) {
            return TableCell.Alignment.CENTER;
        } else if (left) {
            return TableCell.Alignment.LEFT;
        } else {
            return TableCell.Alignment.RIGHT;
        }
    }

    public static class Factory : AbstractBlockParserFactory {

        public BlockStart tryStart(ParserState state, MatchedBlockParser matchedBlockParser) {
            string line = state.getLine();
            string paragraph = matchedBlockParser.getParagraphContent();
            import std.algorithm;

            if (paragraph !is null && paragraph.findSplit("|").length > 0 && paragraph.findSplit("\n").length == 0) {
                string separatorLine = line[state.getIndex()..line.length];
                if (match(separatorLine, TABLE_HEADER_SEPARATOR)) {
                    List!(string) headParts = split(paragraph);
                    List!(string) separatorParts = split(separatorLine);
                    if (separatorParts.size() >= headParts.size()) {
                        return BlockStart.of(new TableBlockParser(paragraph))
                                .atIndex(state.getIndex())
                                .replaceActiveBlockParser();
                    }
                }
            }
            return BlockStart.none();
        }
    }

}
