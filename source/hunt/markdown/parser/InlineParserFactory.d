module hunt.markdown.parser.InlineParserFactory;

import hunt.markdown.parser.InlineParser;
import hunt.markdown.parser.InlineParserContext;

/**
 * Factory for custom inline parser.
 */
public interface InlineParserFactory {
    InlineParser create(InlineParserContext inlineParserContext);
}
