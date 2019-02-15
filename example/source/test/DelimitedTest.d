module test.DelimitedTest;

import hunt.markdown.node;
import hunt.markdown.node.Delimited;
import hunt.markdown.parser.Parser;
import hunt.markdown.node.Visitor;
import hunt.markdown.node.AbstractVisitor;

import hunt.Assert;

import hunt.collection.ArrayList;
import hunt.collection.List;


public class DelimitedTest {

    public void test()
    {
        emphasisDelimiters();
    }

    public void emphasisDelimiters() {
        string input = "* *emphasis* \n"
                ~ "* **strong** \n"
                ~ "* _important_ \n"
                ~ "* __CRITICAL__ \n";

        Parser parser = Parser.builder().build();
        Node document = parser.parse(input);

        List!(Delimited) list = new ArrayList!(Delimited)();
        Visitor visitor = new class AbstractVisitor {
            override
            public void visit(Emphasis node) {
                list.add(node);
            }

            override
            public void visit(StrongEmphasis node) {
                list.add(node);
            }
        };
        document.accept(visitor);

        Assert.assertEquals(4, list.size());

        Delimited emphasis = list.get(0);
        Delimited strong = list.get(1);
        Delimited important = list.get(2);
        Delimited critical = list.get(3);

        Assert.assertEquals("*", emphasis.getOpeningDelimiter());
        Assert.assertEquals("*", emphasis.getClosingDelimiter());
        Assert.assertEquals("**", strong.getOpeningDelimiter());
        Assert.assertEquals("**", strong.getClosingDelimiter());
        Assert.assertEquals("_", important.getOpeningDelimiter());
        Assert.assertEquals("_", important.getClosingDelimiter());
        Assert.assertEquals("__", critical.getOpeningDelimiter());
        Assert.assertEquals("__", critical.getClosingDelimiter());
    }
}
