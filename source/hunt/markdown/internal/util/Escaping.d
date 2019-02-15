module hunt.markdown.internal.util.Escaping;

import hunt.markdown.internal.util.Html5Entities;

// import java.nio.charset.Charset;
import std.algorithm.searching;
// import hunt.time.util.Locale;
import hunt.text;
import hunt.text.StringBuilder;
import std.regex;
import std.string;
import hunt.markdown.internal.util.Common;

class Escaping {

     public enum string ESCAPABLE = "[!\"#$%&\'()*+,./:;<=>?@\\[\\\\\\]^_`{|}~-]";

    private enum string ENTITY = "&(?:#x[a-f0-9]{1,8}|#[0-9]{1,8}|[a-z][a-z0-9]{1,31});";

    private enum string BACKSLASH_OR_AMP = /* Pattern.compile */"[\\\\&]";

    private enum string ENTITY_OR_ESCAPED_CHAR =
            /* Pattern.compile */"\\\\" ~ ESCAPABLE ~ '|' ~ ENTITY;

    private enum string XML_SPECIAL = "[&<>\"]";

    private enum string XML_SPECIAL_RE = /* Pattern.compile */XML_SPECIAL;

    private enum string XML_SPECIAL_OR_ENTITY =
            /* Pattern.compile */ENTITY ~ '|' ~ XML_SPECIAL;

    // From RFC 3986 (see "reserved", "unreserved") except don't escape '[' or ']' to be compatible with JS encodeURI
    private enum string ESCAPE_IN_URI =
            /* Pattern.compile */"(%[a-fA-F0-9]{0,2}|[^:/?#@!$&'()*+,;=a-zA-Z0-9\\-._~])";

    private enum char[] HEX_DIGITS =['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'];

    private enum string WHITESPACE = /* Pattern.compile */"[ \t\r\n]+";

    // private __gshared Replacer UNSAFE_CHAR_REPLACER;

    // private __gshared Replacer UNESCAPE_REPLACER;

    // private __gshared Replacer URI_REPLACER;
        mixin(MakeGlobalVar!(Replacer)("UNSAFE_CHAR_REPLACER",`new class Replacer {
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
        }`));
        mixin(MakeGlobalVar!(Replacer)("UNESCAPE_REPLACER",`new class Replacer {
            override public void replace(string input, StringBuilder sb) {
                if (input[0] == '\\') {
                    sb.append(input, 1, cast(int)input.length);
                } else {
                    sb.append(Html5Entities.entityToString(input));
                }
            }
        }`));
        mixin(MakeGlobalVar!(Replacer)("URI_REPLACER",`new class Replacer {
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
                    byte[] bytes = cast(byte[])input/* .getBytes(Charset.forName("UTF-8")) */;
                    foreach (byte b ; bytes) {
                        sb.append('%');
                        sb.append(HEX_DIGITS[(b >> 4) & 0xF]);
                        sb.append(HEX_DIGITS[b & 0xF]);
                    }
                }
            }
        }`));

    public static string escapeHtml(string input, bool preserveEntities) {
        Regex!char p = preserveEntities ? regex(XML_SPECIAL_OR_ENTITY,"i") : regex(XML_SPECIAL_RE);
        return replaceAll(p, input, UNSAFE_CHAR_REPLACER);
    }

    /**
     * Replace entities and backslash escapes with literal characters.
     */
    public static string unescapeString(string s) {
        if (!matchAll(s,BACKSLASH_OR_AMP).empty()) {
            return replaceAll(regex(ENTITY_OR_ESCAPED_CHAR,"i"), s, UNESCAPE_REPLACER);
        } else {
            return s;
        }
    }

    public static string percentEncodeUrl(string s) {
        return replaceAll(regex(ESCAPE_IN_URI), s, URI_REPLACER);
    }

    public static string normalizeReference(string input) {
        // Strip '[' and ']', then strip
        string stripped = input.substring(1, cast(int)input.length - 1).strip();
        string lowercase = stripped.toLower(/* Locale.ROOT */);
        return std.regex.replaceAll(lowercase,regex(WHITESPACE)," ");
    }

    private static string replaceAll(Regex!char p, string s, Replacer replacer) {
        auto matchers = matchAll(s,p);

        if (matchers.empty()) {
            return s;
        }

        StringBuilder sb = new StringBuilder(s.length + 16);
        int lastEnd = 0;
        // do {
        //     sb.append(s, lastEnd, matcher.start());
        //     replacer.replace(matcher.group(), sb);
        //     lastEnd = matcher.end();
        // } while (matcher.find());
        int offset = 0;
        foreach(matcher; matchers) {
            auto cap = matcher.captures[0];
            auto start =cast(int)(s[offset..$].indexOf(cap)) + offset;
            sb.append(s, lastEnd, start);
            replacer.replace(cap, sb);
            lastEnd = start + cast(int)(cap.length);
            offset = lastEnd;
        }

        if (lastEnd != s.length) {
            sb.append(s, lastEnd, cast(int)s.length);
        }
        return sb.toString();
    }

    private interface Replacer {
        void replace(string input, StringBuilder sb);
    }
}
