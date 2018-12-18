module hunt.markdown.ext.ins.InsExtension;

import hunt.markdown.Extension;
import hunt.markdown.ext.ins.internal.InsDelimiterProcessor;
import hunt.markdown.ext.ins.internal.InsNodeRenderer;
import hunt.markdown.renderer.html.HtmlNodeRendererContext;
import hunt.markdown.renderer.html.HtmlNodeRendererFactory;
import hunt.markdown.parser.Parser;
import hunt.markdown.renderer.html.HtmlRenderer;
import hunt.markdown.renderer.NodeRenderer;

/**
 * Extension for ins using ++
 * <p>
 * Create it with {@link #create()} and then configure it on the builders
 * ({@link hunt.markdown.parser.Parser.Builder#extensions(Iterable)},
 * {@link HtmlRenderer.Builder#extensions(Iterable)}).
 * </p>
 * <p>
 * The parsed ins text regions are turned into {@link Ins} nodes.
 * </p>
 */
class InsExtension : Parser.ParserExtension, HtmlRenderer.HtmlRendererExtension {

    private this() {
    }

    public static Extension create() {
        return new InsExtension();
    }

    override public void extend(Parser.Builder parserBuilder) {
        parserBuilder.customDelimiterProcessor(new InsDelimiterProcessor());
    }

    override public void extend(HtmlRenderer.Builder rendererBuilder) {
        rendererBuilder.nodeRendererFactory(new class HtmlNodeRendererFactory {
            override public NodeRenderer create(HtmlNodeRendererContext context) {
                return new InsNodeRenderer(context);
            }
        });
    }
}
