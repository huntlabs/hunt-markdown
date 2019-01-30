module hunt.markdown.internal.util.Html5Entities;

// import java.io.BufferedReader;
// import hunt.Exceptions;
// import java.io.InputStream;
// import java.io.InputStreamReader;
// import java.nio.charset.Charset;


import hunt.io.Common;
import hunt.collection.HashMap;
import hunt.collection.Map;
import hunt.Exceptions;
import hunt.Integer;
import hunt.text.Common;
import hunt.Char;
import hunt.Exceptions;

import std.regex;
import std.string;

class Html5Entities {

    private __gshared Map!(string, string) NAMED_CHARACTER_REFERENCES;
    private __gshared Regex!char NUMERIC_PATTERN;
    private __gshared string  ENTITY_PATH = "resources/entities.properties";

    static this()
    {
        NAMED_CHARACTER_REFERENCES = readEntities();
        NUMERIC_PATTERN = regex("^&#[Xx]?");
    }

    public static string entityToString(string input) {
        auto matcher = matchAll(input,NUMERIC_PATTERN);

        if (!matcher.empty()) {
            auto group = matcher.front.captures[0];
            auto end = input.indexOf(group) + group.length;
            int base = end == 2 ? 10 : 16;
            try {
                int codePoint = Integer.parseInt(input.substring(end, cast(int)input.length - 1), base);
                if (codePoint == 0) {
                    return "\uFFFD";
                }
                return cast(string)(Char.toChars(codePoint));
            } catch (IllegalArgumentException e) {
                return "\uFFFD";
            }
        } else {
            string name = input.substring(1, cast(int)input.length - 1);
            string s = NAMED_CHARACTER_REFERENCES.get(name);
            if (s !is null) {
                return s;
            } else {
                return input;
            }
        }
    }

    private static Map!(string, string) readEntities() {
        implementationMissing();
        return null;
        // Map!(string, string) entities = new HashMap!(string, string)();
        // InputStream stream = Html5Entities.getResourceAsStream(ENTITY_PATH);
        // Charset charset = Charset.forName("UTF-8");
        // try {
        //     BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(stream, charset));
        //     string line;
        //     while ((line = bufferedReader.readLine()) !is null) {
        //         if (line.length == 0) {
        //             continue;
        //         }
        //         int equal = line.indexOf("=");
        //         string key = line.substring(0, equal);
        //         string value = line.substring(equal + 1);
        //         entities.put(key, value);
        //     }
        // } catch (IOException e) {
        //     throw new IllegalStateException("Failed reading data for HTML named character references", e);
        // }
        // entities.put("NewLine", "\n");
        // return entities;
    }
}
