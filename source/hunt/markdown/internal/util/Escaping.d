module hunt.markdown.internal.util.Escaping;

// import java.nio.charset.Charset;

import hunt.time.util.Locale;
import hunt.string;

import std.regex;

class Escaping {

    public static enum ESCAPABLE = "[!\"#$%&\'()*+,./:;<=>?@\\[\\\\\\]^_`{|}~-]";

    private static enum ENTITY = "&(?:#x[a-f0-9]{1,8}|#[0-9]{1,8}|[a-z][a-z0-9]{1,31});";

    private static enum XML_SPECIAL = "[&<>\"]";

    private static char[] HEX_DIGITS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'];

    private static Regex!char WHITESPACE;

    private static Regex!char BACKSLASH_OR_AMP;

    private static Regex!char ENTITY_OR_ESCAPED_CHAR;

    private static Regex!char XML_SPECIAL_RE;
    
    private static Regex!char XML_SPECIAL_OR_ENTITY;
    
    // From RFC 3986 (see "reserved", "unreserved") except don't escape '[' or ']' to be compatible with JS encodeURI
    private static Regex!char ESCAPE_IN_URI;

    private __gshared Replacer UNSAFE_CHAR_REPLACER;

    private __gshared Replacer UNESCAPE_REPLACER;

    private __gshared Replacer URI_REPLACER;

    static this()
    {
        WHITESPACE = regex("[ \t\r\n]+");
        
        BACKSLASH_OR_AMP = regex("[\\\\&]");

        ENTITY_OR_ESCAPED_CHAR = regex("\\\\" ~ ESCAPABLE + '|' + ENTITY, Pattern.CASE_INSENSITIVE);

        XML_SPECIAL_RE = regex(XML_SPECIAL);

        XML_SPECIAL_OR_ENTITY = regex(ENTITY + '|' + XML_SPECIAL, Pattern.CASE_INSENSITIVE);

        ESCAPE_IN_URI = regex("(%[a-fA-F0-9]{0,2}|[^:/?#@!$&'()*+,;=a-zA-Z0-9\\-._~])");

        UNSAFE_CHAR_REPLACER = new class Replacer {
            override public void replace(string input, StringBuilder sb) {
                switch (input) {
                    case "&":
                        sb.append("&amp;");
                        break;
                    case "<":
                        sb.append("&lt;");
                        break;
                    case ">":
                        sb.append("&gt;");
                        break;
                    case "\"":
                        sb.append("&quot;");
                        break;
                    default:
                        sb.append(input);
                }
            }
        };

        UNESCAPE_REPLACER = new class Replacer {
            override public void replace(string input, StringBuilder sb) {
                if (input[0] == '\\') {
                    sb.append(input, 1, cast(int)input.length);
                } else {
                    sb.append(Html5Entities.entityToString(input));
                }
            }
        };

        URI_REPLACER = new class Replacer {
            override public void replace(string input, StringBuilder sb) {
                if (input.startsWith("%")) {
                    if (input.length == 3) {
                        // Already percent-encoded, preserve
                        sb.append(input);
                    } else {
                        // %25 is the percent-encoding for %
                        sb.append("%25");
                        sb.append(input, 1, cast(int)input.length);
                    }
                } else {
                    byte[] bytes = input.getBytes(Charset.forName("UTF-8"));
                    foreach (byte b ; bytes) {
                        sb.append('%');
                        sb.append(HEX_DIGITS[(b >> 4) & 0xF]);
                        sb.append(HEX_DIGITS[b & 0xF]);
                    }
                }
            }
        };
    }

    public static string escapeHtml(string input, bool preserveEntities) {
        Regex!char p = preserveEntities ? XML_SPECIAL_OR_ENTITY : XML_SPECIAL_RE;
        return replaceAll(p, input, UNSAFE_CHAR_REPLACER);
    }

    /**
     * Replace entities and backslash escapes with literal characters.
     */
    public static string unescapeString(string s) {
        if (BACKSLASH_OR_AMP.matcher(s).find()) {
            return replaceAll(ENTITY_OR_ESCAPED_CHAR, s, UNESCAPE_REPLACER);
        } else {
            return s;
        }
    }

    public static string percentEncodeUrl(string s) {
        return replaceAll(ESCAPE_IN_URI, s, URI_REPLACER);
    }

    public static string normalizeReference(string input) {
        // Strip '[' and ']', then trim
        string stripped = input.substring(1, cast(int)input.length - 1).trim();
        string lowercase = stripped.toLowerCase(Locale.ROOT);
        return WHITESPACE.matcher(lowercase).replaceAll(" ");
    }

    private static string replaceAll(Regex!char p, string s, Replacer replacer) {
        Matcher matcher = p.matcher(s);

        if (!matcher.find()) {
            return s;
        }

        StringBuilder sb = new StringBuilder(s.length + 16);
        int lastEnd = 0;
        do {
            sb.append(s, lastEnd, matcher.start());
            replacer.replace(matcher.group(), sb);
            lastEnd = matcher.end();
        } while (matcher.find());

        if (lastEnd != s.length) {
            sb.append(s, lastEnd, cast(int)s.length);
        }
        return sb.toString();
    }

    private interface Replacer {
        void replace(string input, StringBuilder sb);
    }
}
