module hunt.markdown.internal.ListBlockParser;

import hunt.markdown.internal.util.Parsing;
import hunt.markdown.node.Node;
import hunt.markdown.node.Block;
import hunt.markdown.node.ListBlock;
import hunt.markdown.parser.block.AbstractBlockParser;
import hunt.markdown.parser.block.BlockContinue;
import hunt.markdown.parser.block.ParserState;
import hunt.markdown.parser.block.BlockStart;
import hunt.markdown.parser.block.AbstractBlockParserFactory;
import hunt.markdown.parser.block.MatchedBlockParser;
import hunt.markdown.node.ListItem;
import hunt.markdown.node.OrderedList;
import hunt.markdown.node.BulletList;
import hunt.markdown.parser.block.BlockParser;
import hunt.markdown.internal.ListItemParser;

import hunt.text.Common;
import hunt.Integer;
import hunt.Char;

class ListBlockParser : AbstractBlockParser {

    private ListBlock block;

    private bool hadBlankLine;
    private int linesAfterBlank;

    public this(ListBlock block) {
        this.block = block;
    }

    override public bool isContainer() {
        return true;
    }

    override public bool canContain(Block childBlock) {
        if (cast(ListItem)childBlock !is null) {
            // Another list item is added to this list block. If the previous line was blank, that means this list block
            // is "loose" (not tight).
            //
            // spec: A list is loose if any of its constituent list items are separated by blank lines
            if (hadBlankLine && linesAfterBlank == 1) {
                assert(block !is null);
                block.setTight(false);
                hadBlankLine = false;
            }
            return true;
        } else {
            return false;
        }
    }

    override public Block getBlock() {
        return block;
    }

    public BlockContinue tryContinue(ParserState state) {
        if (state.isBlank()) {
            hadBlankLine = true;
            linesAfterBlank = 0;
        } else if (hadBlankLine) {
            linesAfterBlank++;
        }
        // List blocks themselves don't have any markers, only list items. So try to stay in the list.
        // If there is a block start other than list item, canContain makes sure that this list is closed.
        return BlockContinue.atIndex(state.getIndex());
    }

    /**
     * Parse a list marker and return data on the marker or null.
     */
    private static ListData parseList(string line, int markerIndex, int markerColumn,
                                      bool inParagraph) {
        ListMarkerData listMarker = parseListMarker(line, markerIndex);
        if (listMarker is null) {
            return null;
        }
        ListBlock listBlock = listMarker.listBlock;

        int indexAfterMarker = listMarker.indexAfterMarker;
        int markerLength = indexAfterMarker - markerIndex;
        // marker doesn't include tabs, so counting them as columns directly is ok
        int columnAfterMarker = markerColumn + markerLength;
        // the column within the line where the content starts
        int contentColumn = columnAfterMarker;

        // See at which column the content starts if there is content
        bool hasContent = false;
        int length = cast(int)(line.length);
        for (int i = indexAfterMarker; i < length; i++) {
            char c = line[i];
            if (c == '\t') {
                contentColumn += Parsing.columnsToNextTabStop(contentColumn);
            } else if (c == ' ') {
                contentColumn++;
            } else {
                hasContent = true;
                break;
            }
        }

        if (inParagraph) {
            // If the list item is ordered, the start number must be 1 to interrupt a paragraph.
            if (cast(OrderedList)listBlock !is null && (cast(OrderedList) listBlock).getStartNumber() != 1) {
                return null;
            }
            // Empty list item can not interrupt a paragraph.
            if (!hasContent) {
                return null;
            }
        }

        if (!hasContent || (contentColumn - columnAfterMarker) > Parsing.CODE_BLOCK_INDENT) {
            // If this line is blank or has a code block, default to 1 space after marker
            contentColumn = columnAfterMarker + 1;
        }

        return new ListData(listBlock, contentColumn);
    }

    private static ListMarkerData parseListMarker(string line, int index) {
        char c = line[index];
        switch (c) {
            // spec: A bullet list marker is a -, +, or * character.
            case '-':
            case '+':
            case '*':
                if (isSpaceTabOrEnd(line, index + 1)) {
                    BulletList bulletList = new BulletList();
                    bulletList.setBulletMarker(c);
                    return new ListMarkerData(bulletList, index + 1);
                } else {
                    return null;
                }
            default:
                return parseOrderedList(line, index);
        }
    }

    // spec: An ordered list marker is a sequence of 1–9 arabic digits (0-9), followed by either a `.` character or a
    // `)` character.
    private static ListMarkerData parseOrderedList(string line, int index) {
        int digits = 0;
        int length = cast(int)(line.length);
        for (int i = index; i < length; i++) {
            char c = line[i];
            switch (c) {
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9':
                    digits++;
                    if (digits > 9) {
                        return null;
                    }
                    break;
                case '.':
                case ')':
                    if (digits >= 1 && isSpaceTabOrEnd(line, i + 1)) {
                        string number = line.substring(index, i);
                        OrderedList orderedList = new OrderedList();
                        orderedList.setStartNumber(Integer.parseInt(number));
                        orderedList.setDelimiter(c);
                        return new ListMarkerData(orderedList, i + 1);
                    } else {
                        return null;
                    }
                default:
                    return null;
            }
        }
        return null;
    }

    private static bool isSpaceTabOrEnd(string line, int index) {
        if (index < line.length) {
            switch (line[index]) {
                case ' ':
                case '\t':
                    return true;
                default:
                    return false;
            }
        } else {
            return true;
        }
    }

    /**
     * Returns true if the two list items are of the same type,
     * with the same delimiter and bullet character. This is used
     * in agglomerating list items into lists.
     */
    private static bool listsMatch(ListBlock a, ListBlock b) {
        if (cast(BulletList)a !is null && cast(BulletList)b !is null) {
            return (cast(BulletList) a).getBulletMarker() == (cast(BulletList) b).getBulletMarker();
        } else if (cast(OrderedList)a !is null && cast(OrderedList)b !is null) {
            return (cast(OrderedList) a).getDelimiter() == (cast(OrderedList) b).getDelimiter();
        }
        return false;
    }

    private static bool equals(Object a, Object b) {
        return (a is null) ? (b is null) : (a is b);
    }

    public static class Factory : AbstractBlockParserFactory {

        public BlockStart tryStart(ParserState state, MatchedBlockParser matchedBlockParser) {
            BlockParser matched = matchedBlockParser.getMatchedBlockParser();

            if (state.getIndent() >= Parsing.CODE_BLOCK_INDENT && !(cast(ListBlockParser)matched !is null)) {
                return BlockStart.none();
            }
            int markerIndex = state.getNextNonSpaceIndex();
            int markerColumn = state.getColumn() + state.getIndent();
            bool inParagraph = matchedBlockParser.getParagraphContent() !is null;
            ListData listData = parseList(state.getLine(), markerIndex, markerColumn, inParagraph);
            if (listData is null) {
                return BlockStart.none();
            }

            int newColumn = listData.contentColumn;
            ListItemParser listItemParser = new ListItemParser(newColumn - state.getColumn());

            // prepend the list block if needed
            if (!(cast(ListBlockParser)matched !is null) ||
                    !(listsMatch(cast(ListBlock) (matched.getBlock()), listData.listBlock))) {

                ListBlockParser listBlockParser = new ListBlockParser(listData.listBlock);
                // We start out with assuming a list is tight. If we find a blank line, we set it to loose later.
                listData.listBlock.setTight(true);

                return BlockStart.of(listBlockParser, listItemParser).atColumn(newColumn);
            } else {
                return BlockStart.of(listItemParser).atColumn(newColumn);
            }
        }
    }

    private static class ListData {
        ListBlock listBlock;
        int contentColumn;

        this(ListBlock listBlock, int contentColumn) {
            this.listBlock = listBlock;
            this.contentColumn = contentColumn;
        }
    }

    private static class ListMarkerData {
        ListBlock listBlock;
        int indexAfterMarker;

        this(ListBlock listBlock, int indexAfterMarker) {
            this.listBlock = listBlock;
            this.indexAfterMarker = indexAfterMarker;
        }
    }
}
