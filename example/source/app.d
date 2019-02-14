import std.stdio;

import hunt.markdown.node.Node;
import hunt.markdown.parser.Parser;
import hunt.markdown.renderer.html.HtmlRenderer;
import test.ParserTest;
import test.UsageExampleTest;
import test.HtmlRenderTest;

void main()
{
	writeln("Running ...");

	new UsageExampleTest().test();

	new HtmlRendererTest().test();

	ParserTest.test();

	writeln("All unit tests have been run successfully.");
}
