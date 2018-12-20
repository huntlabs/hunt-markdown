module hunt.markdown.internal.DocumentParser;

import hunt.markdown.internal.ReferenceParser;
import hunt.markdown.internal.util.Parsing;
import hunt.markdown.internal.DocumentBlockParser;
import hunt.markdown.internal.BlockStartImpl;
import hunt.markdown.node.Block;
import hunt.markdown.node.ListBlock;
import hunt.markdown.node.Document;
import hunt.markdown.parser.InlineParser;
import hunt.markdown.parser.block.BlockParser;
import hunt.markdown.parser.block.BlockParserFactory;
import hunt.markdown.parser.block.ParserState;
import hunt.markdown.parser.block.BlockStart;
import hunt.markdown.parser.block.MatchedBlockParser;
import hunt.markdown.parser.block.BlockContinue;

import hunt.container.Map;
import hunt.container.Set;
import hunt.container.List;
import hunt.container.HashSet;
import hunt.lang.exception;

class DocumentParser : ParserState {

    // private __gshared Set<Class<? : Block>> CORE_FACTORY_TYPES = new LinkedHashSet<>(Arrays.asList(
    //         BlockQuote.class,
    //         Heading.class,
    //         FencedCodeBlock.class,
    //         HtmlBlock.class,
    //         ThematicBreak.class,
    //         ListBlock.class,
    //         IndentedCodeBlock.class));

    private static __gshared Set!(TypeInfo) CORE_FACTORY_TYPES;

    private static __gshared Map!(Block, BlockParserFactory) NODES_TO_CORE_FACTORIES;

    static this() {
        CORE_FACTORY_TYPES = new LinkedHashSet!(Block)([
            typeid(BlockQuote),
            typeid(Heading),
            typeid(FencedCodeBlock),
            typeid(HtmlBlock),
            typeid(ThematicBreak),
            typeid(ListBlock),
            typeid(IndentedCodeBlock)]);

        Map!(Block, BlockParserFactory) map = new HashMap!(Block, BlockParserFactory)();
        map.put(typeid(BlockQuote), new BlockQuoteParser.Factory());
        map.put(typeid(Heading), new HeadingParser.Factory());
        map.put(typeid(FencedCodeBlock), new FencedCodeBlockParser.Factory());
        map.put(typeid(HtmlBlock), new HtmlBlockParser.Factory());
        map.put(typeid(ThematicBreak), new ThematicBreakParser.Factory());
        map.put(typeid(ListBlock), new ListBlockParser.Factory());
        map.put(typeid(IndentedCodeBlock), new IndentedCodeBlockParser.Factory());

        NODES_TO_CORE_FACTORIES = Collections.unmodifiableMap(map);
    }

    private string line;

    /**
     * current index (offset) in input line (0-based)
     */
    private int index = 0;

    /**
     * current column of input line (tab causes column to go to next 4-space tab stop) (0-based)
     */
    private int column = 0;

    /**
     * if the current column is within a tab character (partially consumed tab)
     */
    private bool columnIsInTab;

    private int nextNonSpace = 0;
    private int nextNonSpaceColumn = 0;
    private int indent = 0;
    private bool blank;

    private List!(BlockParserFactory) blockParserFactories;
    private InlineParser inlineParser;
    private DocumentBlockParser documentBlockParser;

    private List!(BlockParser) activeBlockParsers = new ArrayList!(BlockParser)();
    private Set!(BlockParser) allBlockParsers = new HashSet!(BlockParser)();

    public this(List!(BlockParserFactory) blockParserFactories, InlineParser inlineParser) {
        this.blockParserFactories = blockParserFactories;
        this.inlineParser = inlineParser;

        this.documentBlockParser = new DocumentBlockParser();
        activateBlockParser(this.documentBlockParser);
    }

    public static Set!(Block) getDefaultBlockParserTypes() {
        return CORE_FACTORY_TYPES;
    }

    public static List!(BlockParserFactory) calculateBlockParserFactories(List!(BlockParserFactory) customBlockParserFactories, Set!(Block) enabledBlockTypes) {
        List!(BlockParserFactory) list = new ArrayList!(BlockParserFactory)();
        // By having the custom factories come first, extensions are able to change behavior of core syntax.
        list.addAll(customBlockParserFactories);
        foreach (Block blockType ; enabledBlockTypes) {
            list.add(NODES_TO_CORE_FACTORIES.get(blockType));
        }
        return list;
    }

    /**
     * The main parsing function. Returns a parsed document AST.
     */
    public Document parse(string input) {
        int lineStart = 0;
        int lineBreak;
        while ((lineBreak = Parsing.findLineBreak(input, lineStart)) != -1) {
            string line = input.substring(lineStart, lineBreak);
            incorporateLine(line);
            if (lineBreak + 1 < input.length() && input[lineBreak] == '\r' && input.charAt(lineBreak + 1) == '\n') {
                lineStart = lineBreak + 2;
            } else {
                lineStart = lineBreak + 1;
            }
        }
        if (input.length() > 0 && (lineStart == 0 || lineStart < input.length())) {
            string line = input.substring(lineStart);
            incorporateLine(line);
        }

        return finalizeAndProcess();
    }

    // public Document parse(Reader input) throws IOException {
    //     BufferedReader bufferedReader;
    //     if (cast(BufferedReader)input !is null) {
    //         bufferedReader = (BufferedReader) input;
    //     } else {
    //         bufferedReader = new BufferedReader(input);
    //     }

    //     string line;
    //     while ((line = bufferedReader.readLine()) !is null) {
    //         incorporateLine(line);
    //     }

    //     return finalizeAndProcess();
    // }

    override public string getLine() {
        return line;
    }

    override public int getIndex() {
        return index;
    }

    override public int getNextNonSpaceIndex() {
        return nextNonSpace;
    }

    override public int getColumn() {
        return column;
    }

    override public int getIndent() {
        return indent;
    }

    override public bool isBlank() {
        return blank;
    }

    override public BlockParser getActiveBlockParser() {
        return activeBlockParsers.get(activeBlockParsers.size() - 1);
    }

    /**
     * Analyze a line of text and update the document appropriately. We parse markdown text by calling this on each
     * line of input, then finalizing the document.
     */
    private void incorporateLine(string ln) {
        line = Parsing.prepareLine(ln);
        index = 0;
        column = 0;
        columnIsInTab = false;

        // For each containing block, try to parse the associated line start.
        // Bail out on failure: container will point to the last matching block.
        // Set all_matched to false if not all containers match.
        // The document will always match, can be skipped
        int matches = 1;
        foreach (BlockParser blockParser ; activeBlockParsers.subList(1, activeBlockParsers.size())) {
            findNextNonSpace();

            BlockContinue result = blockParser.tryContinue(this);
            if (cast(BlockContinueImpl)result !is null) {
                BlockContinueImpl blockContinue = cast(BlockContinueImpl) result;
                if (blockContinue.isFinalize()) {
                    finalize(blockParser);
                    return;
                } else {
                    if (blockContinue.getNewIndex() != -1) {
                        setNewIndex(blockContinue.getNewIndex());
                    } else if (blockContinue.getNewColumn() != -1) {
                        setNewColumn(blockContinue.getNewColumn());
                    }
                    matches++;
                }
            } else {
                break;
            }
        }

        List!(BlockParser) unmatchedBlockParsers = new ArrayList!(BlockParser)(activeBlockParsers.subList(matches, activeBlockParsers.size()));
        BlockParser lastMatchedBlockParser = activeBlockParsers.get(matches - 1);
        BlockParser blockParser = lastMatchedBlockParser;
        bool allClosed = unmatchedBlockParsers.isEmpty();

        // Unless last matched container is a code block, try new container starts,
        // adding children to the last matched container:
        bool tryBlockStarts = cast(Paragraph)blockParser.getBlock() !is null || blockParser.isContainer();
        while (tryBlockStarts) {
            findNextNonSpace();

            // this is a little performance optimization:
            if (isBlank() || (indent < Parsing.CODE_BLOCK_INDENT && Parsing.isLetter(line, nextNonSpace))) {
                setNewIndex(nextNonSpace);
                break;
            }

            BlockStartImpl blockStart = findBlockStart(blockParser);
            if (blockStart == null) {
                setNewIndex(nextNonSpace);
                break;
            }

            if (!allClosed) {
                finalizeBlocks(unmatchedBlockParsers);
                allClosed = true;
            }

            if (blockStart.getNewIndex() != -1) {
                setNewIndex(blockStart.getNewIndex());
            } else if (blockStart.getNewColumn() != -1) {
                setNewColumn(blockStart.getNewColumn());
            }

            if (blockStart.isReplaceActiveBlockParser()) {
                removeActiveBlockParser();
            }

            foreach (BlockParser newBlockParser ; blockStart.getBlockParsers()) {
                blockParser = addChild(newBlockParser);
                tryBlockStarts = newBlockParser.isContainer();
            }
        }

        // What remains at the offset is a text line. Add the text to the
        // appropriate block.

        // First check for a lazy paragraph continuation:
        if (!allClosed && !isBlank() &&
                cast(ParagraphParser)getActiveBlockParser() !is null) {
            // lazy paragraph continuation
            addLine();

        } else {

            // finalize any blocks not matched
            if (!allClosed) {
                finalizeBlocks(unmatchedBlockParsers);
            }

            if (!blockParser.isContainer()) {
                addLine();
            } else if (!isBlank()) {
                // create paragraph container for line
                addChild(new ParagraphParser());
                addLine();
            }
        }
    }

    private void findNextNonSpace() {
        int i = index;
        int cols = column;

        blank = true;
        int length = line.length();
        while (i < length) {
            char c = line[i];
            switch (c) {
                case ' ':
                    i++;
                    cols++;
                    continue;
                case '\t':
                    i++;
                    cols += (4 - (cols % 4));
                    continue;
            }
            blank = false;
            break;
        }

        nextNonSpace = i;
        nextNonSpaceColumn = cols;
        indent = nextNonSpaceColumn - column;
    }

    private void setNewIndex(int newIndex) {
        if (newIndex >= nextNonSpace) {
            // We can start from here, no need to calculate tab stops again
            index = nextNonSpace;
            column = nextNonSpaceColumn;
        }
        int length = line.length();
        while (index < newIndex && index != length) {
            advance();
        }
        // If we're going to an index as opposed to a column, we're never within a tab
        columnIsInTab = false;
    }

    private void setNewColumn(int newColumn) {
        if (newColumn >= nextNonSpaceColumn) {
            // We can start from here, no need to calculate tab stops again
            index = nextNonSpace;
            column = nextNonSpaceColumn;
        }
        int length = line.length();
        while (column < newColumn && index != length) {
            advance();
        }
        if (column > newColumn) {
            // Last character was a tab and we overshot our target
            index--;
            column = newColumn;
            columnIsInTab = true;
        } else {
            columnIsInTab = false;
        }
    }

    private void advance() {
        char c = line[index];
        if (c == '\t') {
            index++;
            column += Parsing.columnsToNextTabStop(column);
        } else {
            index++;
            column++;
        }
    }

    /**
     * Add line content to the active block parser. We assume it can accept lines -- that check should be done before
     * calling this.
     */
    private void addLine() {
        string content;
        if (columnIsInTab) {
            // Our column is in a partially consumed tab. Expand the remaining columns (to the next tab stop) to spaces.
            int afterTab = index + 1;
            string rest = line.subSequence(afterTab, line.length());
            int spaces = Parsing.columnsToNextTabStop(column);
            StringBuilder sb = new StringBuilder(spaces ~ rest.length());
            for (int i = 0; i < spaces; i++) {
                sb.append(' ');
            }
            sb.append(rest);
            content = sb.toString();
        } else {
            content = line.subSequence(index, line.length());
        }
        getActiveBlockParser().addLine(content);
    }

    private BlockStartImpl findBlockStart(BlockParser blockParser) {
        MatchedBlockParser matchedBlockParser = new MatchedBlockParserImpl(blockParser);
        foreach (BlockParserFactory blockParserFactory ; blockParserFactories) {
            BlockStart result = blockParserFactory.tryStart(this, matchedBlockParser);
            if (cast(BlockStartImpl)result !is null) {
                return cast(BlockStartImpl) result;
            }
        }
        return null;
    }

    /**
     * Finalize a block. Close it and do any necessary postprocessing, e.g. creating string_content from strings,
     * setting the 'tight' or 'loose' status of a list, and parsing the beginnings of paragraphs for reference
     * definitions.
     */
    private void finalize(BlockParser blockParser) {
        if (getActiveBlockParser() == blockParser) {
            deactivateBlockParser();
        }

        blockParser.closeBlock();

        if (cast(ParagraphParser)blockParser !is null
                && cast(ReferenceParser)inlineParser !is null) {
            ParagraphParser paragraphParser = cast(ParagraphParser) blockParser;
            paragraphParser.closeBlock(cast(ReferenceParser) inlineParser);
        }
    }

    /**
     * Walk through a block & children recursively, parsing string content into inline content where appropriate.
     */
    private void processInlines() {
        foreach (BlockParser blockParser ; allBlockParsers) {
            blockParser.parseInlines(inlineParser);
        }
    }

    /**
     * Add block of type tag as a child of the tip. If the tip can't  accept children, close and finalize it and try
     * its parent, and so on til we find a block that can accept children.
     */
    private T addChild(T)(T blockParser) {
        while (!getActiveBlockParser().canContain(blockParser.getBlock())) {
            finalize(getActiveBlockParser());
        }

        getActiveBlockParser().getBlock().appendChild(blockParser.getBlock());
        activateBlockParser(blockParser);

        return blockParser;
    }

    private void activateBlockParser(BlockParser blockParser) {
        activeBlockParsers.add(blockParser);
        allBlockParsers.add(blockParser);
    }

    private void deactivateBlockParser() {
        activeBlockParsers.remove(activeBlockParsers.size() - 1);
    }

    private void removeActiveBlockParser() {
        BlockParser old = getActiveBlockParser();
        deactivateBlockParser();
        allBlockParsers.remove(old);

        old.getBlock().unlink();
    }

    /**
     * Finalize blocks of previous line. Returns true.
     */
    private void finalizeBlocks(List!(BlockParser) blockParsers) {
        for (int i = blockParsers.size() - 1; i >= 0; i--) {
            BlockParser blockParser = blockParsers.get(i);
            finalize(blockParser);
        }
    }

    private Document finalizeAndProcess() {
        finalizeBlocks(this.activeBlockParsers);
        this.processInlines();
        return this.documentBlockParser.getBlock();
    }

    private static class MatchedBlockParserImpl : MatchedBlockParser {

        private BlockParser matchedBlockParser;

        public this(BlockParser matchedBlockParser) {
            this.matchedBlockParser = matchedBlockParser;
        }

        override public BlockParser getMatchedBlockParser() {
            return matchedBlockParser;
        }

        override public string getParagraphContent() {
            if (cast(ParagraphParser)matchedBlockParser !is null) {
                ParagraphParser paragraphParser = cast(ParagraphParser) matchedBlockParser;
                return paragraphParser.getContentString();
            }
            return null;
        }
    }
}
