module hunt.markdown.ext.strikethrough.StrikethroughExtension;

import hunt.markdown.Extension;
import hunt.markdown.renderer.text.TextContentRenderer;
import hunt.markdown.renderer.text.TextContentNodeRendererContext;
import hunt.markdown.renderer.text.TextContentNodeRendererFactory;
import hunt.markdown.ext.gfm.strikethrough.internal.StrikethroughDelimiterProcessor;
import hunt.markdown.ext.gfm.strikethrough.internal.StrikethroughHtmlNodeRenderer;
import hunt.markdown.ext.gfm.strikethrough.internal.StrikethroughTextContentNodeRenderer;
import hunt.markdown.renderer.html.HtmlRenderer;
import hunt.markdown.renderer.html.HtmlNodeRendererContext;
import hunt.markdown.renderer.html.HtmlNodeRendererFactory;
import hunt.markdown.parser.Parser;
import hunt.markdown.renderer.NodeRenderer;

/**
 * Extension for GFM strikethrough using ~~ (GitHub Flavored Markdown).
 * <p>
 * Create it with {@link #create()} and then configure it on the builders
 * ({@link hunt.markdown.parser.Parser.Builder#extensions(Iterable)},
 * {@link HtmlRenderer.Builder#extensions(Iterable)}).
 * </p>
 * <p>
 * The parsed strikethrough text regions are turned into {@link Strikethrough} nodes.
 * </p>
 */
class StrikethroughExtension : Parser.ParserExtension, HtmlRenderer.HtmlRendererExtension,
        TextContentRenderer.TextContentRendererExtension {

    private this() {
    }

    public static Extension create() {
        return new StrikethroughExtension();
    }

    override public void extend(Parser.Builder parserBuilder) {
        parserBuilder.customDelimiterProcessor(new StrikethroughDelimiterProcessor());
    }

    override public void extend(HtmlRenderer.Builder rendererBuilder) {
        rendererBuilder.nodeRendererFactory(new class HtmlNodeRendererFactory {
            override public NodeRenderer create(HtmlNodeRendererContext context) {
                return new StrikethroughHtmlNodeRenderer(context);
            }
        });
    }

    override public void extend(TextContentRenderer.Builder rendererBuilder) {
        rendererBuilder.nodeRendererFactory(new class TextContentNodeRendererFactory {
            override public NodeRenderer create(TextContentNodeRendererContext context) {
                return new StrikethroughTextContentNodeRenderer(context);
            }
        });
    }
}
