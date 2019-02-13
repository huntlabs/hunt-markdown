import std.stdio;

import hunt.markdown.node.Node;
import hunt.markdown.parser.Parser;
import hunt.markdown.renderer.html.HtmlRenderer;
import test.ParserTest;

void main()
{
	writeln("Edit source/app.d to start your project.");

	Parser parser = Parser.builder().build();
	Node document = parser.parse("This is *Sparta*"); //This is *Sparta*
	HtmlRenderer renderer = HtmlRenderer.builder().build();
	assert(renderer.render(document) == "<p>This is <em>Sparta</em></p>\n"); // "<p>This is <em>Sparta</em></p>\n"

	ParserTest.fileTest();
}
