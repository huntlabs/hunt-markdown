import std.stdio;

import hunt.markdown.node.Node;
import hunt.markdown.parser.Parser;
import hunt.markdown.renderer.html.HtmlRenderer;
import test.ParserTest;
import test.UsageExampleTest;
import test.HtmlRenderTest;
import test.DelimitedTest;
import test.FencedCodeBlockParserTest;
import test.HeadingParserTest;
import test.ListTightLooseTest;
import test.SpecialInputTest;
import test.TextContentRendererTest;

void main()
{
	writeln("Running ...");

	new UsageExampleTest().test();

	new HtmlRendererTest().test();

	ParserTest.test();

	new DelimitedTest().test();

	new FencedCodeBlockParserTest().test();

	new HeadingParserTest().test();

	new ListTightLooseTest().test();

	new SpecialInputTest().test();

	new TextContentRendererTest().test();

	writeln("All unit tests have been run successfully.");
}
