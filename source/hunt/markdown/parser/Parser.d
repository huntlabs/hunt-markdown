module hunt.markdown.parser.Parser;

import hunt.markdown.Extension;
import hunt.markdown.internal.DocumentParser;
import hunt.markdown.internal.InlineParserImpl;
import hunt.markdown.node.Node;
import hunt.markdown.node.Block;
import hunt.markdown.parser.block.BlockParserFactory;
import hunt.markdown.parser.delimiter.DelimiterProcessor;
import hunt.markdown.parser.InlineParserContext;
import hunt.markdown.parser.InlineParserFactory;
import hunt.markdown.parser.InlineParser;
import hunt.markdown.parser.PostProcessor;

import hunt.Exceptions;
import hunt.util.Common;
import hunt.collection.ArrayList;
import hunt.collection.List;
import hunt.collection.Set;

/**
 * Parses input text to a tree of nodes.
 * <p>
 * Start with the {@link #builder} method, configure the parser and build it. Example:
 * <pre><code>
 * Parser parser = Parser.builder().build();
 * Node document = parser.parse("input text");
 * </code></pre>
 */
class Parser {

    private List!(BlockParserFactory) blockParserFactories;
    private List!(DelimiterProcessor) delimiterProcessors;
    private InlineParserFactory _inlineParserFactory;
    private List!(PostProcessor) postProcessors;

    private this(Builder builder) {
        this.blockParserFactories = DocumentParser.calculateBlockParserFactories(builder.blockParserFactories, builder._enabledBlockTypes);
        this._inlineParserFactory = builder._inlineParserFactory;
        this.postProcessors = builder.postProcessors;
        this.delimiterProcessors = builder.delimiterProcessors;

        // Try to construct an inline parser. This might raise exceptions in case of invalid configuration.
        getInlineParser();
    }

    /**
     * Create a new builder for configuring a {@link Parser}.
     *
     * @return a builder
     */
    public static Builder builder() {
        return new Builder();
    }

    /**
     * Parse the specified input text into a tree of nodes.
     * <p>
     * This method is thread-safe (a new parser state is used for each invocation).
     *
     * @param input the text to parse
     * @return the root node
     */
    public Node parse(string input) {
        InlineParser inlineParser = getInlineParser();
        DocumentParser documentParser = new DocumentParser(blockParserFactories, inlineParser);
        Node document = documentParser.parse(input);
        return postProcess(document);
    }

    /**
     * Parse the specified reader into a tree of nodes. The caller is responsible for closing the reader.
     * <pre><code>
     * Parser parser = Parser.builder().build();
     * try (InputStreamReader reader = new InputStreamReader(new FileInputStream("file.md"), StandardCharsets.UTF_8)) {
     *     Node document = parser.parseReader(reader);
     *     // ...
     * }
     * </code></pre>
     * Note that if you have a file with a byte order mark (BOM), you need to skip it before handing the reader to this
     * library. There's existing classes that do that, e.g. see {@code BOMInputStream} in Commons IO.
     * <p>
     * This method is thread-safe (a new parser state is used for each invocation).
     *
     * @param input the reader to parse
     * @return the root node
     * @throws IOException when reading throws an exception
     */
    // public Node parseReader(Reader input)
    // {
    //     InlineParser inlineParser = getInlineParser();
    //     DocumentParser documentParser = new DocumentParser(blockParserFactories, inlineParser);
    //     Node document = documentParser.parse(input);
    //     return postProcess(document);
    // }

    private InlineParser getInlineParser() {
        if (this._inlineParserFactory is null) {
            return new InlineParserImpl(delimiterProcessors);
        } else {
            CustomInlineParserContext inlineParserContext = new CustomInlineParserContext(delimiterProcessors);
            return this._inlineParserFactory.create(inlineParserContext);
        }
    }

    private Node postProcess(Node document) {
        foreach (PostProcessor postProcessor ; postProcessors) {
            document = postProcessor.process(document);
        }
        return document;
    }

    private class CustomInlineParserContext : InlineParserContext {

        private List!(DelimiterProcessor) delimiterProcessors;

        this(List!(DelimiterProcessor) delimiterProcessors) {
            this.delimiterProcessors = delimiterProcessors;
        }

        override public List!(DelimiterProcessor) getCustomDelimiterProcessors() {
            return delimiterProcessors;
        }
    }

    /**
     * Builder for configuring a {@link Parser}.
     */
    public static class Builder {
        private List!(BlockParserFactory) blockParserFactories;
        private List!(DelimiterProcessor) delimiterProcessors;
        private List!(PostProcessor) postProcessors;
        private Set!(TypeInfo_Class) _enabledBlockTypes;
        private InlineParserFactory _inlineParserFactory = null;

        this()
        {
            blockParserFactories = new ArrayList!(BlockParserFactory)();
            delimiterProcessors = new ArrayList!(DelimiterProcessor)();
            postProcessors = new ArrayList!(PostProcessor)();
            _enabledBlockTypes = DocumentParser.getDefaultBlockParserTypes();
        }

        /**
         * @return the configured {@link Parser}
         */
        public Parser build() {
            return new Parser(this);
        }

        /**
         * @param extensions extensions to use on this parser
         * @return {@code this}
         */
        public Builder extensions(Iterable!Extension extensions) {
            foreach (Extension extension ; extensions) {
                if (cast(ParserExtension)extension !is null) {
                    ParserExtension parserExtension = cast(ParserExtension) extension;
                    parserExtension.extend(this);
                }
            }
            return this;
        }

        /**
         * Describe the list of markdown features the parser will recognize and parse.
         * <p>
         * By default, CommonMark will recognize and parse the following set of "block" elements:
         * <ul>
         * <li>{@link Heading} ({@code #})
         * <li>{@link HtmlBlock} ({@code <html></html>})
         * <li>{@link ThematicBreak} (Horizontal Rule) ({@code ---})
         * <li>{@link FencedCodeBlock} ({@code ```})
         * <li>{@link IndentedCodeBlock}
         * <li>{@link BlockQuote} ({@code >})
         * <li>{@link ListBlock} (Ordered / Unordered List) ({@code 1. / *})
         * </ul>
         * <p>
         * To parse only a subset of the features listed above, pass a list of each feature's associated {@link Block} class.
         * <p>
         * E.g., to only parse headings and lists:
         * <pre>
         *     {@code
         *     Parser.builder().enabledBlockTypes(new HashSet<>(Arrays.asList(Heading.class, ListBlock.class)));
         *     }
         * </pre>
         *
         * @param enabledBlockTypes A list of block nodes the parser will parse.
         * If this list is empty, the parser will not recognize any CommonMark core features.
         * @return {@code this}
         */
        public Builder enabledBlockTypes(Set!TypeInfo_Class enabledBlockTypes) {
            if (enabledBlockTypes is null) {
                throw new NullPointerException("enabledBlockTypes must not be null");
            }
            this._enabledBlockTypes = enabledBlockTypes;
            return this;
        }

        /**
         * Adds a custom block parser factory.
         * <p>
         * Note that custom factories are applied <em>before</em> the built-in factories. This is so that
         * extensions can change how some syntax is parsed that would otherwise be handled by built-in factories.
         * "With great power comes great responsibility."
         *
         * @param blockParserFactory a block parser factory implementation
         * @return {@code this}
         */
        public Builder customBlockParserFactory(BlockParserFactory blockParserFactory) {
            blockParserFactories.add(blockParserFactory);
            return this;
        }

        /**
         * Adds a custom delimiter processor.
         * <p>
         * Note that multiple delimiter processors with the same characters can be added, as long as they have a
         * different minimum length. In that case, the processor with the shortest matching length is used. Adding more
         * than one delimiter processor with the same character and minimum length is invalid.
         *
         * @param delimiterProcessor a delimiter processor implementation
         * @return {@code this}
         */
        public Builder customDelimiterProcessor(DelimiterProcessor delimiterProcessor) {
            delimiterProcessors.add(delimiterProcessor);
            return this;
        }

        public Builder postProcessor(PostProcessor postProcessor) {
            postProcessors.add(postProcessor);
            return this;
        }

        /**
         * Overrides the parser used for inline markdown processing.
         * <p>
         * Provide an implementation of InlineParserFactory which provides a custom inline parser
         * to modify how the following are parsed:
         * bold (**)
         * italic (*)
         * strikethrough (~~)
         * backtick quote (`)
         * link ([title](http://))
         * image (![alt](http://))
         * <p>
         * <p>
         * Note that if this method is not called or the inline parser factory is set to null, then the default
         * implementation will be used.
         *
         * @param inlineParserFactory an inline parser factory implementation
         * @return {@code this}
         */
        public Builder inlineParserFactory(InlineParserFactory inlineParserFactory) {
            this._inlineParserFactory = inlineParserFactory;
            return this;
        }
    }

    /**
     * Extension for {@link Parser}.
     */
    public interface ParserExtension : Extension {
        void extend(Builder parserBuilder);
    }
}
