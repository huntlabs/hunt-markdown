module test.UsageExampleTest;

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

public class UsageExampleTest {

    public void test()
    {
        parseAndRender();
        visitor();
        addAttributes();
        customizeRendering();
    }
    public void parseAndRender() {
        Parser parser = Parser.builder().build();
        Node document = parser.parse("This is *Sparta*");
        HtmlRenderer renderer = HtmlRenderer.builder().escapeHtml(true).build();
        Assert.assertEquals("<p>This is <em>Sparta</em></p>\n", renderer.render(document));
    }

    
    
    public void parseReaderRender()  {
        Parser parser = Parser.builder().build();
        // try (InputStreamReader reader = new InputStreamReader(new FileInputStream("file.md"), StandardCharsets.UTF_8)) {
        //     Node document = parser.parseReader(reader);
        //     // ...
        // }
    }

    
    public void visitor() {
        Parser parser = Parser.builder().build();
        Node node = parser.parse("Example\n=======\n\nSome more text");
        WordCountVisitor visitor = new WordCountVisitor();
        node.accept(visitor);
        Assert.assertEquals(4, visitor.wordCount);
    }

    
    public void addAttributes() {
        Parser parser = Parser.builder().build();
        HtmlRenderer renderer = HtmlRenderer.builder()
                .attributeProviderFactory(new class AttributeProviderFactory {
                    public AttributeProvider create(AttributeProviderContext context) {
                        return new ImageAttributeProvider();
                    }
                })
                .build();

        Node document = parser.parse("![text](/url.png)");
        Assert.assertEquals("<p><img src=\"/url.png\" alt=\"text\" class=\"border\" /></p>\n",
                renderer.render(document));
    }

    
    public void customizeRendering() {
        Parser parser = Parser.builder().build();
        HtmlRenderer renderer = HtmlRenderer.builder()
                .nodeRendererFactory(new class HtmlNodeRendererFactory {
                    public NodeRenderer create(HtmlNodeRendererContext context) {
                        return new IndentedCodeBlockNodeRenderer(context);
                    }
                })
                .build();

        Node document = parser.parse("Example:\n\n    code");
        Assert.assertEquals("<p>Example:</p>\n<pre>code\n</pre>\n", renderer.render(document));
    }

    class WordCountVisitor : AbstractVisitor {

        int wordCount = 0;

        override
        public void visit(Text text) {
            // This is called for all Text nodes. Override other visit methods for other node types.

            // Count words (this is just an example, don't actually do it this way for various reasons).
            import std.regex;
            wordCount += text.getLiteral().split(regex("\\W+")).length;

            // Descend into children (could be omitted in this case because Text nodes don't have children).
            visitChildren(text);
        }
    }

    class ImageAttributeProvider : AttributeProvider {
        override
        public void setAttributes(Node node, string tagName, Map!(string,string) attributes) {
            if (cast(Image)node !is null) {
                attributes.put("class", "border");
            }
        }
    }

    class IndentedCodeBlockNodeRenderer : NodeRenderer {

        private  HtmlWriter html;

        this(HtmlNodeRendererContext context) {
            this.html = context.getWriter();
        }

        override
        public Set!(TypeInfo_Class) getNodeTypes() {
            // Return the node types we want to use this renderer for.
            return new HashSet!(TypeInfo_Class)([typeid(IndentedCodeBlock)]);
        }

        override
        public void render(Node node) {
            // We only handle one type as per getNodeTypes, so we can just cast it here.
            IndentedCodeBlock codeBlock = cast(IndentedCodeBlock) node;
            html.line();
            html.tag("pre");
            html.text(codeBlock.getLiteral());
            html.tag("/pre");
            html.line();
        }
    }
}
