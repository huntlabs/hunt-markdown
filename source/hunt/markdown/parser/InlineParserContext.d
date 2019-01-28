module hunt.markdown.parser.InlineParserContext;

import hunt.markdown.parser.delimiter.DelimiterProcessor;

import hunt.collection.List;

/**
 * Parameter context for custom inline parser.
 */
public interface InlineParserContext {
    List!(DelimiterProcessor) getCustomDelimiterProcessors();
}
