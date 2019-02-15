module test.SpecialInputTest;

import test.CoreRenderingTestCase;
import test.Common;

public class SpecialInputTest : CoreRenderingTestCase {

    public void test()
    {
        empty();
        nullCharacterShouldBeReplaced();
        nullCharacterEntityShouldBeReplaced();
        crLfAsLineSeparatorShouldBeParsed();
        crLfAtEndShouldBeParsed();
        mixedLineSeparators();
        surrogatePair();
        surrogatePairInLinkDestination();
        indentedCodeBlockWithMixedTabsAndSpaces();
        tightListInBlockQuote();
        looseListInBlockQuote();
        lineWithOnlySpacesAfterListBullet();
        listWithTwoSpacesForFirstBullet();
        orderedListMarkerOnly();
        columnIsInTabOnPreviousLine();
        linkLabelWithBracket();
        linkLabelLength();
        linkDestinationEscaping();
        linkReferenceBackslash();
        emphasisMultipleOf3Rule();
    }
    
    public void empty() {
        assertRendering("", "");
    }

    
    public void nullCharacterShouldBeReplaced() {
        assertRendering("foo\0bar", "<p>foo\uFFFDbar</p>\n");
    }

    
    public void nullCharacterEntityShouldBeReplaced() {
        assertRendering("foo&#0;bar", "<p>foo\uFFFDbar</p>\n");
    }

    
    public void crLfAsLineSeparatorShouldBeParsed() {
        assertRendering("foo\r\nbar", "<p>foo\nbar</p>\n");
    }

    
    public void crLfAtEndShouldBeParsed() {
        assertRendering("foo\r\n", "<p>foo</p>\n");
    }

    
    public void mixedLineSeparators() {
        assertRendering("- a\n- b\r- c\r\n- d", "<ul>\n<li>a</li>\n<li>b</li>\n<li>c</li>\n<li>d</li>\n</ul>\n");
        assertRendering("a\n\nb\r\rc\r\n\r\nd\n\re", "<p>a</p>\n<p>b</p>\n<p>c</p>\n<p>d</p>\n<p>e</p>\n");
    }

    
    public void surrogatePair() {
        assertRendering("surrogate pair: \u4F60\u597D", "<p>surrogate pair: \u4F60\u597D</p>\n");
    }

    
    public void surrogatePairInLinkDestination() {
        assertRendering("[title](\u4F60\u597D)", "<p><a href=\"\u4F60\u597D\">title</a></p>\n");
    }

    
    public void indentedCodeBlockWithMixedTabsAndSpaces() {
        assertRendering("    foo\n\tbar", "<pre><code>foo\nbar\n</code></pre>\n");
    }

    
    public void tightListInBlockQuote() {
        assertRendering("> *\n> * a", "<blockquote>\n<ul>\n<li></li>\n<li>a</li>\n</ul>\n</blockquote>\n");
    }

    
    public void looseListInBlockQuote() {
        // Second line in block quote is considered blank for purpose of loose list
        assertRendering("> *\n>\n> * a", "<blockquote>\n<ul>\n<li></li>\n<li>\n<p>a</p>\n</li>\n</ul>\n</blockquote>\n");
    }

    
    public void lineWithOnlySpacesAfterListBullet() {
        assertRendering("-  \n  \n  foo\n", "<ul>\n<li></li>\n</ul>\n<p>foo</p>\n");
    }

    
    public void listWithTwoSpacesForFirstBullet() {
        // We have two spaces after the bullet, but no content. With content, the next line would be required
        assertRendering("*  \n  foo\n", "<ul>\n<li>foo</li>\n</ul>\n");
    }

    
    public void orderedListMarkerOnly() {
        assertRendering("2.", "<ol start=\"2\">\n<li></li>\n</ol>\n");
    }

    
    public void columnIsInTabOnPreviousLine() {
        assertRendering("- foo\n\n\tbar\n\n# baz\n",
                "<ul>\n<li>\n<p>foo</p>\n<p>bar</p>\n</li>\n</ul>\n<h1>baz</h1>\n");
        assertRendering("- foo\n\n\tbar\n# baz\n",
                "<ul>\n<li>\n<p>foo</p>\n<p>bar</p>\n</li>\n</ul>\n<h1>baz</h1>\n");
    }

    
    public void linkLabelWithBracket() {
        assertRendering("[a[b]\n\n[a[b]: /", "<p>[a[b]</p>\n<p>[a[b]: /</p>\n");
        assertRendering("[a]b]\n\n[a]b]: /", "<p>[a]b]</p>\n<p>[a]b]: /</p>\n");
        assertRendering("[a[b]]\n\n[a[b]]: /", "<p>[a[b]]</p>\n<p>[a[b]]: /</p>\n");
    }

    
    public void linkLabelLength() {
        string label1 = repeat("a", 999);
        assertRendering("[foo][" ~ label1 ~ "]\n\n[" ~ label1 ~ "]: /", "<p><a href=\"/\">foo</a></p>\n");
        assertRendering("[foo][x" ~ label1 ~ "]\n\n[x" ~ label1 ~ "]: /",
                "<p>[foo][x" ~ label1 ~ "]</p>\n<p>[x" ~ label1 ~ "]: /</p>\n");
        assertRendering("[foo][\n" ~ label1 ~ "]\n\n[\n" ~ label1 ~ "]: /",
                "<p>[foo][\n" ~ label1 ~ "]</p>\n<p>[\n" ~ label1 ~ "]: /</p>\n");

        string label2 = repeat("a\n", 499);
        assertRendering("[foo][" ~ label2 ~ "]\n\n[" ~ label2 ~ "]: /", "<p><a href=\"/\">foo</a></p>\n");
        assertRendering("[foo][12" ~ label2 ~ "]\n\n[12" ~ label2 ~ "]: /",
                "<p>[foo][12" ~ label2 ~ "]</p>\n<p>[12" ~ label2 ~ "]: /</p>\n");
    }

    
    public void linkDestinationEscaping() {
        // Backslash escapes `)`
        assertRendering("[foo](\\))", "<p><a href=\")\">foo</a></p>\n");
        // ` ` is not escapable, so the backslash is a literal backslash and there's an optional space at the end
        assertRendering("[foo](\\ )", "<p><a href=\"\\\">foo</a></p>\n");
        // Backslash escapes `>`, so it's not a `(<...>)` link, but a `(...)` link instead
        assertRendering("[foo](<\\>)", "<p><a href=\"&lt;&gt;\">foo</a></p>\n");
        // Backslash is a literal, so valid
        assertRendering("[foo](<a\\b>)", "<p><a href=\"a\\b\">foo</a></p>\n");
        // Backslash escapes `>` but there's another `>`, valid
        assertRendering("[foo](<a\\>>)", "<p><a href=\"a&gt;\">foo</a></p>\n");
    }

    // commonmark/CommonMark#468
    
    public void linkReferenceBackslash() {
        // Backslash escapes ']', so not a valid link label
        assertRendering("[\\]: test", "<p>[]: test</p>\n");
        // Backslash is a literal, so valid
        assertRendering("[a\\b]\n\n[a\\b]: test", "<p><a href=\"test\">a\\b</a></p>\n");
        // Backslash escapes `]` but there's another `]`, valid
        assertRendering("[a\\]]\n\n[a\\]]: test", "<p><a href=\"test\">a]</a></p>\n");
    }

    // commonmark/cmark#177
    
    public void emphasisMultipleOf3Rule() {
        // assertRendering("a***b* c*", "<p>a*<em><em>b</em> c</em></p>\n");
    }
}
