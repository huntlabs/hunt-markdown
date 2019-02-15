module test.FencedCodeBlockParserTest;


import hunt.markdown.node.FencedCodeBlock;
import hunt.markdown.node.Node;
import hunt.markdown.parser.Parser;
import hunt.markdown.renderer.html.HtmlRenderer;
import test.RenderingTestCase;
import hunt.Assert;


public class FencedCodeBlockParserTest : RenderingTestCase {

    private static Parser PARSER ;
    private static HtmlRenderer RENDERER;

    static this()
    {
        PARSER = Parser.builder().build();
        RENDERER = HtmlRenderer.builder().build();
    }
    
    public void test()
    {
        backtickInfo();
        backtickInfoDoesntAllowBacktick();
        backtickAndTildeCantBeMixed();
        closingCanHaveSpacesAfter();
        closingCanNotHaveNonSpaces();
    }

    public void backtickInfo() {
        Node document = PARSER.parse("```info ~ test\ncode\n```");
        FencedCodeBlock codeBlock = cast(FencedCodeBlock) (document.getFirstChild());
        Assert.assertEquals("info ~ test", codeBlock.getInfo());
        Assert.assertEquals("code\n", codeBlock.getLiteral());
    }

    
    public void backtickInfoDoesntAllowBacktick() {
        assertRendering("```info ` test\ncode\n```",
                "<p>```info ` test\ncode</p>\n<pre><code></code></pre>\n");
        // Note, it's unclear in the spec whether a ~~~ code block can contain ` in info or not, see:
        // https://github.com/commonmark/CommonMark/issues/119
    }

    
    public void backtickAndTildeCantBeMixed() {
        assertRendering("``~`\ncode\n``~`",
                "<p><code>~` code</code>~`</p>\n");
    }

    
    public void closingCanHaveSpacesAfter() {
        assertRendering("```\ncode\n```   ",
                "<pre><code>code\n</code></pre>\n");
    }

    
    public void closingCanNotHaveNonSpaces() {
        assertRendering("```\ncode\n``` a",
                "<pre><code>code\n``` a\n</code></pre>\n");
    }

    override
    protected string render(string source) {
        return RENDERER.render(PARSER.parse(source));
    }
}
