module hunt.markdown.internal.ParagraphParser;

import hunt.markdown.internal.ReferenceParser;
import hunt.markdown.internal.util.Parsing;
import hunt.markdown.internal.BlockContent;
import hunt.markdown.node.Block;
import hunt.markdown.node.Paragraph;
import hunt.markdown.parser.block.AbstractBlockParser;
import hunt.markdown.parser.block.BlockContinue;
import hunt.markdown.parser.InlineParser;
import hunt.markdown.parser.block.ParserState;

import hunt.text.Common;

class ParagraphParser : AbstractBlockParser {

    private Paragraph block;
    private BlockContent content;

    this()
    {
        block = new Paragraph();
        content = new BlockContent();
    }

    public Block getBlock() {
        return block;
    }

    public BlockContinue tryContinue(ParserState state) {
        if (!state.isBlank()) {
            return BlockContinue.atIndex(state.getIndex());
        } else {
            return BlockContinue.none();
        }
    }

    override public void addLine(string line) {
        content.add(line);
    }

    override public void closeBlock() {
    }

    public void closeBlock(ReferenceParser inlineParser) {
        string contentString = content.getString();
        bool hasReferenceDefs = false;

        int pos;
        // try parsing the beginning as link reference definitions:
        while (contentString.length > 3 && contentString[0] == '[' &&
                (pos = inlineParser.parseReference(contentString)) != 0) {
            contentString = contentString.substring(pos);
            hasReferenceDefs = true;
        }
        if (hasReferenceDefs && Parsing.isBlank(contentString)) {
            block.unlink();
            content = null;
        } else {
            content = new BlockContent(contentString);
        }
    }

    override public void parseInlines(InlineParser inlineParser) {
        if (content !is null) {
            inlineParser.parse(content.getString(), block);
        }
    }

    public string getContentString() {
        return content.getString();
    }
}
