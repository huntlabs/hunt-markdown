module hunt.markdown.ext.front.matter.YamlFrontMatterExtension;

import hunt.markdown.Extension;
import hunt.markdown.ext.matter.internal.YamlFrontMatterBlockParser;
import hunt.markdown.parser.Parser;
import hunt.markdown.renderer.html.HtmlRenderer;

/**
 * Extension for YAML-like metadata.
 * <p>
 * Create it with {@link #create()} and then configure it on the builders
 * ({@link hunt.markdown.parser.Parser.Builder#extensions(Iterable)},
 * {@link HtmlRenderer.Builder#extensions(Iterable)}).
 * </p>
 * <p>
 * The parsed metadata is turned into {@link YamlFrontMatterNode}. You can access the metadata using {@link YamlFrontMatterVisitor}.
 * </p>
 */
class YamlFrontMatterExtension : Parser.ParserExtension {

    private this() {
    }

    override public void extend(Parser.Builder parserBuilder) {
        parserBuilder.customBlockParserFactory(new YamlFrontMatterBlockParser.Factory());
    }

    public static Extension create() {
        return new YamlFrontMatterExtension();
    }
}
