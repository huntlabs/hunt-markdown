module test.CoreRenderingTestCase;

import hunt.markdown.parser.Parser;
import hunt.markdown.renderer.html.HtmlRenderer;
import test.RenderingTestCase;

public class CoreRenderingTestCase : RenderingTestCase {

    private static Parser PARSER;
    private static HtmlRenderer RENDERER;

    static this()
    {
        PARSER = Parser.builder().build();
        RENDERER = HtmlRenderer.builder().build();
    }

    override
    protected string render(string source) {
        return RENDERER.render(PARSER.parse(source));
    }
}