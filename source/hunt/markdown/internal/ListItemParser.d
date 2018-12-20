module hunt.markdown.internal.ListItemParser;

import hunt.markdown.node.Block;
import hunt.markdown.node.ListBlock;
import hunt.markdown.node.ListItem;
import hunt.markdown.node.Paragraph;
import hunt.markdown.parser.block.AbstractBlockParser;
import hunt.markdown.parser.block.BlockContinue;
import hunt.markdown.parser.block.ParserState;

class ListItemParser : AbstractBlockParser {

    private ListItem block;

    /**
     * Minimum number of columns that the content has to be indented (relative to the containing block) to be part of
     * this list item.
     */
    private int contentIndent;

    private bool hadBlankLine;

    public this(int contentIndent) {
        block = new ListItem();
        this.contentIndent = contentIndent;
    }

    override public bool isContainer() {
        return true;
    }

    override public bool canContain(Block childBlock) {
        if (hadBlankLine) {
            // We saw a blank line in this list item, that means the list block is loose.
            //
            // spec: if any of its constituent list items directly contain two block-level elements with a blank line
            // between them
            Block parent = block.getParent();
            if (cast(ListBlock)parent !is null) {
                (cast(ListBlock) parent).setTight(false);
            }
        }
        return true;
    }

    public Block getBlock() {
        return block;
    }

    public BlockContinue tryContinue(ParserState state) {
        if (state.isBlank()) {
            if (block.getFirstChild() is null) {
                // Blank line after empty list item
                return BlockContinue.none();
            } else {
                Block activeBlock = state.getActiveBlockParser().getBlock();
                // If the active block is a code block, blank lines in it should not affect if the list is tight.
                hadBlankLine = cast(Paragraph)activeBlock !is null || cast(ListItem)activeBlock !is null;
                return BlockContinue.atIndex(state.getNextNonSpaceIndex());
            }
        }

        if (state.getIndent() >= contentIndent) {
            return BlockContinue.atColumn(state.getColumn() + contentIndent);
        } else {
            return BlockContinue.none();
        }
    }
}
