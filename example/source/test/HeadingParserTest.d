module test.HeadingParserTest;

import hunt.markdown.parser.Parser;
import hunt.markdown.renderer.html.HtmlRenderer;
import test.RenderingTestCase;
import hunt.Assert;

public class HeadingParserTest : RenderingTestCase {

    private static  Parser PARSER;
    private static  HtmlRenderer RENDERER;

    static this()
    {
        PARSER = Parser.builder().build();
        RENDERER = HtmlRenderer.builder().build();
    }
    
    public void test()
    {
        atxHeadingStart();
        atxHeadingTrailing();
        atxHeadingSurrogates();
        setextHeadingMarkers();
    }

    public void atxHeadingStart() {
        assertRendering("# test", "<h1>test</h1>\n");
        assertRendering("###### test", "<h6>test</h6>\n");
        assertRendering("####### test", "<p>####### test</p>\n");
        assertRendering("#test", "<p>#test</p>\n");
        assertRendering("#", "<h1></h1>\n");
    }

    
    public void atxHeadingTrailing() {
        assertRendering("# test #", "<h1>test</h1>\n");
        assertRendering("# test ###", "<h1>test</h1>\n");
        assertRendering("# test # ", "<h1>test</h1>\n");
        assertRendering("# test  ###  ", "<h1>test</h1>\n");
        assertRendering("# test # #", "<h1>test #</h1>\n");
        assertRendering("# test#", "<h1>test#</h1>\n");
    }

    
    public void atxHeadingSurrogates() {
        assertRendering("# \u4F60\u597D #", "<h1>\u4F60\u597D</h1>\n");
    }

    
    public void setextHeadingMarkers() {
        assertRendering("test\n=", "<h1>test</h1>\n");
        assertRendering("test\n-", "<h2>test</h2>\n");
        assertRendering("test\n====", "<h1>test</h1>\n");
        assertRendering("test\n----", "<h2>test</h2>\n");
        assertRendering("test\n====   ", "<h1>test</h1>\n");
        assertRendering("test\n====   =", "<p>test\n====   =</p>\n");
        assertRendering("test\n=-=", "<p>test\n=-=</p>\n");
        assertRendering("test\n=a", "<p>test\n=a</p>\n");
    }

    override
    protected string render(string source) {
        return RENDERER.render(PARSER.parse(source));
    }
}
