module hunt.markdown.parser.InlineParserContext;

import hunt.markdown.parser.delimiter.DelimiterProcessor;

import hunt.container.List;

/**
 * Parameter context for custom inline parser.
 */
public interface InlineParserContext {
    List!(DelimiterProcessor) getCustomDelimiterProcessors();
}
