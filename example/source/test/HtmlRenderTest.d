module test.HtmlRenderTest;

import hunt.markdown.node;
import hunt.markdown.parser.Parser;
import hunt.markdown.renderer.NodeRenderer;
import hunt.markdown.renderer.html;
import hunt.markdown.node.AbstractVisitor;
import hunt.markdown.renderer.html.AttributeProvider;
import hunt.markdown.renderer.html.HtmlWriter;
import hunt.markdown.renderer.html.HtmlNodeRendererContext;
import hunt.markdown.renderer.html.HtmlRenderer;
import hunt.markdown.renderer.html.AttributeProviderContext;
import hunt.markdown.renderer.html.AttributeProviderFactory;
import hunt.markdown.renderer.html.HtmlNodeRendererFactory;

import hunt.collection.Map;
import hunt.collection.Set;
import hunt.collection.HashSet;
import hunt.Assert;
import std.conv;
import hunt.logging;

public class HtmlRendererTest {

    public void test()
    {
        htmlAllowingShouldNotEscapeInlineHtml();
        // htmlAllowingShouldNotEscapeBlockHtml();
        // htmlEscapingShouldEscapeInlineHtml();
        // htmlEscapingShouldEscapeHtmlBlocks();
        // textEscaping();
        // percentEncodeUrlDisabled();
        // percentEncodeUrl();
        // attributeProviderForCodeBlock();
        // attributeProviderForImage();
        // attributeProviderFactoryNewInstanceForEachRender();
        // overrideNodeRender();
        // orderedListStartZero();
        // imageAltTextWithSoftLineBreak();
        // imageAltTextWithHardLineBreak();
        // imageAltTextWithEntities();
    }
    
    public void htmlAllowingShouldNotEscapeInlineHtml() {
        string rendered = htmlAllowingRenderer().render(parse("paragraph with <span id='foo' class=\"bar\">inline &amp; html</span>"));
        version(HUNT_DEBUG)logDebug("--expect : ",rendered);
        Assert.assertEquals("<p>paragraph with <span id='foo' class=\"bar\">inline &amp;\n html</span></p>\n", rendered);
    }

    
    public void htmlAllowingShouldNotEscapeBlockHtml() {
        string rendered = htmlAllowingRenderer().render(parse("<div id='foo' class=\"bar\">block &amp;</div>"));
        Assert.assertEquals("<div id='foo' class=\"bar\">block &amp;</div>\n", rendered);
    }

    
    public void htmlEscapingShouldEscapeInlineHtml() {
        string rendered = htmlEscapingRenderer().render(parse("paragraph with <span id='foo' class=\"bar\">inline &amp; html</span>"));
        // Note that &amp; is not escaped, as it's a normal text node, not part of the inline HTML.
        version(HUNT_DEBUG)logDebug("--expect2 : ",rendered);
        Assert.assertEquals("<p>paragraph with &lt;span id='foo' class=&quot;bar&quot;&gt;inline &amp;\n html&lt;/span&gt;</p>\n", rendered);
    }

    
    public void htmlEscapingShouldEscapeHtmlBlocks() {
        string rendered = htmlEscapingRenderer().render(parse("<div id='foo' class=\"bar\">block &amp;</div>"));
        Assert.assertEquals("<p>&lt;div id='foo' class=&quot;bar&quot;&gt;block &amp;amp;&lt;/div&gt;</p>\n", rendered);
    }

    
    public void textEscaping() {
        string rendered = defaultRenderer().render(parse("escaping: & < > \" '"));
        Assert.assertEquals("<p>escaping: &amp; &lt; &gt; &quot; '</p>\n", rendered);
    }

    
    public void percentEncodeUrlDisabled() {
        version(HUNT_DEBUG)logDebug("--expect3 : ",defaultRenderer().render(parse("[a](foo&amp;bar)")));
        Assert.assertEquals("<p><a href=\"foo&amp;\nbar\">a</a></p>\n", defaultRenderer().render(parse("[a](foo&amp;bar)")));
        version(HUNT_DEBUG)logDebug("--expect4 : ",defaultRenderer().render(parse("[a](ä)")));
        Assert.assertEquals("<p><a href=\"ä\">a</a></p>\n", defaultRenderer().render(parse("[a](ä)")));
        Assert.assertEquals("<p><a href=\"foo%20bar\">a</a></p>\n", defaultRenderer().render(parse("[a](foo%20bar)")));
    }

    
    public void percentEncodeUrl() {
        // Entities are escaped anyway
        version(HUNT_DEBUG)logDebug("--expect5 : ", percentEncodingRenderer().render(parse("[a](foo&amp;bar)")));
        Assert.assertEquals("<p><a href=\"foo&amp;%0Abar\">a</a></p>\n", percentEncodingRenderer().render(parse("[a](foo&amp;bar)")));
        // Existing encoding is preserved
        Assert.assertEquals("<p><a href=\"foo%20bar\">a</a></p>\n", percentEncodingRenderer().render(parse("[a](foo%20bar)")));
        Assert.assertEquals("<p><a href=\"foo%61\">a</a></p>\n", percentEncodingRenderer().render(parse("[a](foo%61)")));
        // Invalid encoding is escaped
        Assert.assertEquals("<p><a href=\"foo%25\">a</a></p>\n", percentEncodingRenderer().render(parse("[a](foo%)")));
        Assert.assertEquals("<p><a href=\"foo%25a\">a</a></p>\n", percentEncodingRenderer().render(parse("[a](foo%a)")));
        Assert.assertEquals("<p><a href=\"foo%25a_\">a</a></p>\n", percentEncodingRenderer().render(parse("[a](foo%a_)")));
        Assert.assertEquals("<p><a href=\"foo%25xx\">a</a></p>\n", percentEncodingRenderer().render(parse("[a](foo%xx)")));
        // Reserved characters are preserved, except for '[' and ']'
        Assert.assertEquals("<p><a href=\"!*'();:@&amp;=+$,/?#%5B%5D\">a</a></p>\n", percentEncodingRenderer().render(parse("[a](!*'();:@&=+$,/?#[])")));
        // Unreserved characters are preserved
        Assert.assertEquals("<p><a href=\"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~\">a</a></p>\n",
                percentEncodingRenderer().render(parse("[a](ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~)")));
        // Other characters are percent-encoded (LATIN SMALL LETTER A WITH DIAERESIS)
        Assert.assertEquals("<p><a href=\"%C3%A4\">a</a></p>\n",
                percentEncodingRenderer().render(parse("[a](ä)")));
        // Other characters are percent-encoded (你好, surrogate pair in UTF-16)
        version(HUNT_DEBUG)logDebug("--expect6 : ",percentEncodingRenderer().render(parse("[a](\u4F60\u597D)")));
        Assert.assertEquals("<p><a href=\"%E4%BD%A0%E5%A5%BD\">a</a></p>\n",
                percentEncodingRenderer().render(parse("[a](\u4F60\u597D)")));
    }

    
    public void attributeProviderForCodeBlock() {
        AttributeProviderFactory custom = new class AttributeProviderFactory {
            override
            public AttributeProvider create(AttributeProviderContext context) {
                return new class AttributeProvider {
                    override
                    public void setAttributes(Node node, string tagName, Map!(string,string) attributes) {
                        if(cast(FencedCodeBlock)node !is null && tagName==("code")) {
                            FencedCodeBlock fencedCodeBlock = cast(FencedCodeBlock) node;
                            // Remove the default attribute for info
                            attributes.remove("class");
                            // Put info in custom attribute instead
                            attributes.put("data-custom", fencedCodeBlock.getInfo());
                        } else if(cast(FencedCodeBlock)node !is null && tagName==("pre")) {
                            attributes.put("data-code-block", "fenced");
                        }
                    }
                };
            }
        };

        HtmlRenderer renderer = HtmlRenderer.builder().attributeProviderFactory(custom).build();
        string rendered = renderer.render(parse("```info\ncontent\n```"));
        Assert.assertEquals("<pre data-code-block=\"fenced\"><code data-custom=\"info\">content\n</code></pre>\n", rendered);

        string rendered2 = renderer.render(parse("```evil\"\ncontent\n```"));
        Assert.assertEquals("<pre data-code-block=\"fenced\"><code data-custom=\"evil&quot;\">content\n</code></pre>\n", rendered2);
    }

    
    public void attributeProviderForImage() {
        AttributeProviderFactory custom = new class AttributeProviderFactory {
            override
            public AttributeProvider create(AttributeProviderContext context) {
                return new class AttributeProvider {
                    override
                    public void setAttributes(Node node, string tagName, Map!(string,string) attributes) {
                        if (cast(Image)node !is null) {
                            attributes.remove("alt");
                            attributes.put("test", "hey");
                        }
                    }
                };
            }
        };

        HtmlRenderer renderer = HtmlRenderer.builder().attributeProviderFactory(custom).build();
        string rendered = renderer.render(parse("![foo](/url)\n"));
        Assert.assertEquals("<p><img src=\"/url\" test=\"hey\" /></p>\n", rendered);
    }

    
    public void attributeProviderFactoryNewInstanceForEachRender() {
        AttributeProviderFactory factory = new class AttributeProviderFactory {
            override
            public AttributeProvider create(AttributeProviderContext context) {
                return new class AttributeProvider {
                    int i = 0;

                    override
                    public void setAttributes(Node node, string tagName, Map!(string,string) attributes) {
                        attributes.put("key", "" ~ i.to!string);
                        i++;
                    }
                };
            }
        };

        HtmlRenderer renderer = HtmlRenderer.builder().attributeProviderFactory(factory).build();
        string rendered = renderer.render(parse("text node"));
        string secondPass = renderer.render(parse("text node"));
        Assert.assertEquals(rendered, secondPass);
    }

    
    public void overrideNodeRender() {
        HtmlNodeRendererFactory nodeRendererFactory = new class HtmlNodeRendererFactory {
            override
            public NodeRenderer create( HtmlNodeRendererContext context) {
                return new class NodeRenderer {
                    override
                    public Set!TypeInfo_Class getNodeTypes() {
                        return new HashSet!TypeInfo_Class([typeid(Link)]);
                    }

                    override
                    public void render(Node node) {
                        context.getWriter().text("test");
                    }
                };
            }
        };

        HtmlRenderer renderer = HtmlRenderer.builder().nodeRendererFactory(nodeRendererFactory).build();
        string rendered = renderer.render(parse("foo [bar](/url)"));
        Assert.assertEquals("<p>foo test</p>\n", rendered);
    }

    
    public void orderedListStartZero() {
        version(HUNT_DEBUG)logDebug("--expect7 : ", defaultRenderer().render(parse("0. Test\n")));
        Assert.assertEquals("<ol start=\"0\">\n<li>Test</li>\n</ol>\n", defaultRenderer().render(parse("0. Test\n")));
    }

    
    public void imageAltTextWithSoftLineBreak() {
        Assert.assertEquals("<p><img src=\"/url\" alt=\"foo\nbar\" /></p>\n",
                defaultRenderer().render(parse("![foo\nbar](/url)\n")));
    }

    
    public void imageAltTextWithHardLineBreak() {
        Assert.assertEquals("<p><img src=\"/url\" alt=\"foo\nbar\" /></p>\n",
                defaultRenderer().render(parse("![foo  \nbar](/url)\n")));
    }

    
    public void imageAltTextWithEntities() {
        version(HUNT_DEBUG)logDebug("--expect8 : ", defaultRenderer().render(parse("![foo &auml;](/url)\n")));
        Assert.assertEquals("<p><img src=\"/url\" alt=\"foo ä\n\" /></p>\n",
                defaultRenderer().render(parse("![foo &auml;](/url)\n")));
    }

    
    public void threading()  {
        import hunt.concurrency.Future;
        import hunt.concurrency.ExecutorService;
        import hunt.concurrency.Executors;
        import hunt.collection.ArrayList;
        import hunt.collection.List;
        import hunt.util.StringBuilder;
        import hunt.Exceptions;
        import hunt.util.Common;
        import std.file;
        import std.stdio;

        Parser parser = Parser.builder().build();
        auto readPath = "./resources/spec.txt";
        auto reader = File(readPath,"r");
        StringBuilder sb = new StringBuilder();
        try {
            string line;
            while ((line = reader.readln()) != null) {
                sb.append(line);
                sb.append("\n");
            }
            
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        string spec = sb.toString;
        Node document = parser.parse(spec);

        HtmlRenderer htmlRenderer = HtmlRenderer.builder().build();
        string expectedRendering = htmlRenderer.render(document);

        // Render in parallel using the same HtmlRenderer instance.
        List!(Future!(string)) futures = new ArrayList!(Future!(string))();
        ExecutorService executorService = Executors.newFixedThreadPool(4);
        // for (int i = 0; i < 40; i++) {
        //     Future!(string) future = executorService.submit(new class Callable!(string) {
        //         override
        //         public string call()  {
        //             return htmlRenderer.render(document);
        //         }
        //     });
        //     futures.add(future);
        // }

        // foreach(Future!(string) future ; futures) {
        //     string rendering = future.get();
        //     assertThat(rendering, is(expectedRendering));
        // }
    }

    private static HtmlRenderer defaultRenderer() {
        return HtmlRenderer.builder().build();
    }

    private static HtmlRenderer htmlAllowingRenderer() {
        return HtmlRenderer.builder().escapeHtml(false).build();
    }

    private static HtmlRenderer htmlEscapingRenderer() {
        return HtmlRenderer.builder().escapeHtml(true).build();
    }

    private static HtmlRenderer percentEncodingRenderer() {
        return HtmlRenderer.builder().percentEncodeUrls(true).build();
    }

    private static Node parse(string source) {
        return Parser.builder().build().parse(source);
    }
}
