module test.RenderingTestCase;

import hunt.Assert;
import std.string;
import hunt.logging;

public abstract class RenderingTestCase {

    protected abstract string render(string source);

    protected void assertRendering(string source, string expectedResult) {
        string renderedContent = render(source);

        // include source for better assertion errors
        string expected = showTabs(expectedResult ~ "\n\n" ~ source);
        string actual = showTabs(renderedContent ~ "\n\n" ~ source);
        // logInfo("actual : ",actual);
        // logInfo("expected : ",expected);
        Assert.assertEquals(expected, actual);
    }

    private static string showTabs(string s) {
        // Tabs are shown as "rightwards arrow" for easier comparison
        return s.replace("\t", "\u2192");
    }
}
