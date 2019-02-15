module test.TextContentRendererTest;

import hunt.markdown.renderer.text.TextContentRenderer;
import hunt.markdown.node.Node;
import hunt.markdown.parser.Parser;
import hunt.Assert;


public class TextContentRendererTest {

    public void test(){
        textContentText();
        textContentEmphasis();
        textContentQuotes();
        textContentLinks();
        textContentImages();
        textContentLists();
        textContentCode();
        textContentCodeBlock();
        textContentBrakes();
        // textContentHtml();
    }
    
    public void textContentText() {
        string source;
        string rendered;

        source = "foo bar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("foo bar", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("foo bar", rendered);

        source = "foo foo\n\nbar\nbar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("foo foo\nbar\nbar", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("foo foo bar bar", rendered);
    }

    
    public void textContentEmphasis() {
        string source;
        string rendered;

        source = "***foo***";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("foo", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("foo", rendered);

        source = "foo ***foo*** bar ***bar***";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("foo foo bar bar", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("foo foo bar bar", rendered);

        source = "foo\n***foo***\nbar\n\n***bar***";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("foo\nfoo\nbar\nbar", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("foo foo bar bar", rendered);
    }

    
    public void textContentQuotes() {
        string source;
        string rendered;

        source = "foo\n>foo\nbar\n\nbar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("foo\n«foo\nbar»\nbar", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("foo «foo bar» bar", rendered);
    }

    
    public void textContentLinks() {
        string source;
        string expected;
        string rendered;

        source = "foo [text](http://link \"title\") bar";
        expected = "foo \"text\" (title: http://link) bar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals(expected, rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals(expected, rendered);

        source = "foo [text](http://link \"http://link\") bar";
        expected = "foo \"text\" (http://link) bar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals(expected, rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals(expected, rendered);

        source = "foo [text](http://link) bar";
        expected = "foo \"text\" (http://link) bar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals(expected, rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals(expected, rendered);

        source = "foo [text]() bar";
        expected = "foo \"text\" bar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals(expected, rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals(expected, rendered);

        source = "foo http://link bar";
        expected = "foo http://link bar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals(expected, rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals(expected, rendered);
    }

    
    public void textContentImages() {
        string source;
        string expected;
        string rendered;

        source = "foo ![text](http://link \"title\") bar";
        expected = "foo \"text\" (title: http://link) bar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals(expected, rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals(expected, rendered);

        source = "foo ![text](http://link) bar";
        expected = "foo \"text\" (http://link) bar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals(expected, rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals(expected, rendered);

        source = "foo ![text]() bar";
        expected = "foo \"text\" bar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals(expected, rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals(expected, rendered);
    }

    
    public void textContentLists() {
        string source;
        string rendered;

        source = "foo\n* foo\n* bar\n\nbar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("foo\n* foo\n* bar\nbar", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("foo foo bar bar", rendered);

        source = "foo\n- foo\n- bar\n\nbar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("foo\n- foo\n- bar\nbar", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("foo foo bar bar", rendered);

        source = "foo\n1. foo\n2. bar\n\nbar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("foo\n1. foo\n2. bar\nbar", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("foo 1. foo 2. bar bar", rendered);

        source = "foo\n0) foo\n1) bar\n\nbar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("foo\n0) foo\n1) bar\nbar", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("foo 0) foo 1) bar bar", rendered);

        source = "bar\n1. foo\n   1. bar\n2. foo";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("bar\n1. foo\n   1. bar\n2. foo", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("bar 1. foo 1. bar 2. foo", rendered);

        source = "bar\n* foo\n   - bar\n* foo";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("bar\n* foo\n   - bar\n* foo", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("bar foo bar foo", rendered);

        source = "bar\n* foo\n   1. bar\n   2. bar\n* foo";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("bar\n* foo\n   1. bar\n   2. bar\n* foo", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("bar foo 1. bar 2. bar foo", rendered);

        source = "bar\n1. foo\n   * bar\n   * bar\n2. foo";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("bar\n1. foo\n   * bar\n   * bar\n2. foo", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("bar 1. foo bar bar 2. foo", rendered);
    }

    
    public void textContentCode() {
        string source;
        string expected;
        string rendered;

        source = "foo `code` bar";
        expected = "foo \"code\" bar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals(expected, rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals(expected, rendered);
    }

    
    public void textContentCodeBlock() {
        string source;
        string rendered;

        source = "foo\n```\nfoo\nbar\n```\nbar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("foo\nfoo\nbar\nbar", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("foo foo bar bar", rendered);

        source = "foo\n\n    foo\n     bar\nbar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("foo\nfoo\n bar\nbar", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("foo foo bar bar", rendered);
    }

    
    public void textContentBrakes() {
        string source;
        string rendered;

        source = "foo\nbar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("foo\nbar", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("foo bar", rendered);

        source = "foo  \nbar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("foo\nbar", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("foo bar", rendered);

        source = "foo\n___\nbar";
        rendered = defaultRenderer().render(parse(source));
        Assert.assertEquals("foo\n***\nbar", rendered);
        rendered = strippedRenderer().render(parse(source));
        Assert.assertEquals("foo bar", rendered);
    }

    
    public void textContentHtml() {
        string rendered;

        string html = "<table>\n" ~
                "  <tr>\n" ~
                "    <td>\n" ~
                "           foobar\n" ~
                "    </td>\n" ~
                "  </tr>\n" ~
                "</table>";
        rendered = defaultRenderer().render(parse(html));
        import hunt.logging;
        logInfo("expect : ",html);
        logInfo("actual : ",rendered);
        Assert.assertEquals(html, rendered);

        html = "foo <foo>foobar</foo> bar";
        rendered = defaultRenderer().render(parse(html));
        Assert.assertEquals(html, rendered);
    }

    private TextContentRenderer defaultRenderer() {
        return TextContentRenderer.builder().build();
    }

    private TextContentRenderer strippedRenderer() {
        return TextContentRenderer.builder().stripNewlines(true).build();
    }

    private Node parse(string source) {
        return Parser.builder().build().parse(source);
    }
}
