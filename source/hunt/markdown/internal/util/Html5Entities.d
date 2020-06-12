module hunt.markdown.internal.util.Html5Entities;

// import java.io.BufferedReader;
// import hunt.Exceptions;
// import java.io.InputStream;
// import java.io.InputStreamReader;
// import java.nio.charset.Charset;

// import hunt.io.Common;
import hunt.collection.HashMap;
import hunt.collection.Map;
import hunt.Exceptions;
import hunt.Integer;
import hunt.text.Common;
import hunt.Char;
import hunt.Exceptions;
import hunt.markdown.internal.util.Common;

import std.regex;
import std.string;
import std.stdio;

class Html5Entities
{

    mixin(MakeGlobalVar!(Map!(string, string))("NAMED_CHARACTER_REFERENCES",`readEntities()`));
    private __gshared string NUMERIC_PATTERN = "^&#[Xx]?";
    private __gshared string ENTITY_PATH = "resources/entities.properties";

    public static string entityToString(string input)
    {
        auto matcher = matchAll(input, NUMERIC_PATTERN);

        if (!matcher.empty())
        {
            auto group = matcher.front.captures[0];
            auto end = input.indexOf(group) + group.length;
            int base = end == 2 ? 10 : 16;
            try
            {
                int codePoint = Integer.parseInt(input.substring(end,
                        cast(int) input.length - 1), base);
                if (codePoint == 0)
                {
                    return "\uFFFD";
                }
                return cast(string)(Char.toChars(codePoint));
            }
            catch (IllegalArgumentException e)
            {
                return "\uFFFD";
            }
        }
        else
        {
            string name = input.substring(1, cast(int) input.length - 1);
            string s = NAMED_CHARACTER_REFERENCES.get(name);
            if (s !is null)
            {
                return s;
            }
            else
            {
                return input;
            }
        }
    }

    private static Map!(string, string) readEntities()
    {

        Map!(string, string) entities = new HashMap!(string, string)();

        auto f = File(ENTITY_PATH, "r");
        try
        {
            string line;
            while ((line = f.readln()) !is null)
            {
                if (line.length == 0)
                {
                    continue;
                }
                int equal = cast(int)(line.indexOf("="));
                string key = line.substring(0, equal);
                string value = line.substring(equal + 1);
                entities.put(key, value);
            }
        }
        catch (IOException e)
        {
            throw new IllegalStateException(
                    "Failed reading data for HTML named character references", e);
        }

        entities.put("NewLine", "\n");

        return entities;
    }
}
