module test.ParserTest;

import hunt.markdown.node;
import hunt.markdown.parser.InlineParser;
import hunt.markdown.parser.InlineParserContext;
import hunt.markdown.parser.InlineParserFactory;
import hunt.markdown.parser.Parser;
import hunt.markdown.parser.block;
import hunt.markdown.renderer.html.HtmlRenderer;
import hunt.Assert;
import hunt.text.StringBuilder;
import hunt.Exceptions;
import std.stdio;
import std.file : read,write;

public class ParserTest {

    
    public static void fileTest()  {
        Parser parser = Parser.builder().build();

        auto readPath = "./resources/spec.txt";
        auto writePath = "./resources/spec.html";
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
        Node document2 = parser.parse(spec);

        HtmlRenderer renderer = HtmlRenderer.builder().escapeHtml(true).build();
        write(writePath,renderer.render(document2));
    }
}
