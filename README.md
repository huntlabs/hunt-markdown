# hunt-markdown
A markdown parsing and rendering library for D programming language.

## Parse and render

```D
import hunt.markdown.node.Node;
import hunt.markdown.parser.Parser;
import hunt.markdown.renderer.html.HtmlRenderer;

Parser parser = Parser.builder().build();
Node document = parser.parse("This is *New*");
HtmlRenderer renderer = HtmlRenderer.builder().build();
renderer.render(document);  // "<p>This is <em>New</em></p>\n"
```
