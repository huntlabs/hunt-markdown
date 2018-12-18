module hunt.markdown.ext.table.TableExtension;

import hunt.markdown.Extension;
import hunt.markdown.ext.table.internal.TableBlockParser;
import hunt.markdown.ext.table.internal.TableHtmlNodeRenderer;
import hunt.markdown.ext.table.internal.TableTextContentNodeRenderer;
import hunt.markdown.renderer.html.HtmlRenderer;
import hunt.markdown.renderer.html.HtmlNodeRendererContext;
import hunt.markdown.renderer.html.HtmlNodeRendererFactory;
import hunt.markdown.parser.Parser;
import hunt.markdown.renderer.NodeRenderer;
import hunt.markdown.renderer.text.TextContentNodeRendererContext;
import hunt.markdown.renderer.text.TextContentNodeRendererFactory;
import hunt.markdown.renderer.text.TextContentRenderer;

/**
 * Extension for GFM tables using "|" pipes (GitHub Flavored Markdown).
 * <p>
 * Create it with {@link #create()} and then configure it on the builders
 * ({@link hunt.markdown.parser.Parser.Builder#extensions(Iterable)},
 * {@link HtmlRenderer.Builder#extensions(Iterable)}).
 * </p>
 * <p>
 * The parsed tables are turned into {@link TableBlock} blocks.
 * </p>
 */
class TableExtension : Parser.ParserExtension, HtmlRenderer.HtmlRendererExtension,
        TextContentRenderer.TextContentRendererExtension {

    private this() {
    }

    public static Extension create() {
        return new TableExtension();
    }

    override public void extend(Parser.Builder parserBuilder) {
        parserBuilder.customBlockParserFactory(new TableBlockParser.Factory());
    }

    override public void extend(HtmlRenderer.Builder rendererBuilder) {
        rendererBuilder.nodeRendererFactory(new class HtmlNodeRendererFactory {
            override public NodeRenderer create(HtmlNodeRendererContext context) {
                return new TableHtmlNodeRenderer(context);
            }
        });
    }

    override public void extend(TextContentRenderer.Builder rendererBuilder) {
        rendererBuilder.nodeRendererFactory(new class TextContentNodeRendererFactory {
            override public NodeRenderer create(TextContentNodeRendererContext context) {
                return new TableTextContentNodeRenderer(context);
            }
        });
    }
}
