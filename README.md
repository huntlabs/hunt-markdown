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

## How to use Tables extension?

```D
string markdown = `
## Test for tables
| head 1 | head 2 |  head 3 |
|--------|--------|--------|
| row 1.1 |  row 1.2 |  row 1.3 |
| row 2.1 |  row 2.2 |  row 2.3  |
`;

auto extensions = Collections.singleton(TableExtension.create());

Parser parser = Parser.builder().extensions(extensions).build();
Node document = parser.parse(markdown);
HtmlRenderer renderer = HtmlRenderer.builder().extensions(extensions).build();

renderer.render(document);
```
