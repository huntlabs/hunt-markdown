module hunt.markdown.internal.util.Parsing;
import hunt.Char;
import hunt.util.StringBuilder;
import hunt.text.Common;
import hunt.logging;
alias Character = Char;

class Parsing {

    private const string TAGNAME = "[A-Za-z][A-Za-z0-9-]*";
    private const string ATTRIBUTENAME = "[a-zA-Z_:][a-zA-Z0-9:._-]*";
    private const string UNQUOTEDVALUE = "[^\"'=<>`\\x00-\\x20]+";
    private const string SINGLEQUOTEDVALUE = "'[^']*'";
    private const string DOUBLEQUOTEDVALUE = "\"[^\"]*\"";

    private const string ATTRIBUTEVALUE = "(?:" ~ UNQUOTEDVALUE ~ "|" ~ SINGLEQUOTEDVALUE ~ "|" ~ DOUBLEQUOTEDVALUE ~ ")";
    private const string ATTRIBUTEVALUESPEC = "(?:" ~ "\\s*=" ~ "\\s*" ~ ATTRIBUTEVALUE ~ ")";
    private const string ATTRIBUTE = "(?:" ~ "\\s+" ~ ATTRIBUTENAME ~ ATTRIBUTEVALUESPEC ~ "?)";

    public enum string OPENTAG = "<" ~ TAGNAME ~ ATTRIBUTE ~ "*" ~ "\\s*/?>";
    public enum string CLOSETAG = "</" ~ TAGNAME ~ "\\s*[>]";

    public enum int CODE_BLOCK_INDENT = 4;

    public static int columnsToNextTabStop(int column) {
        // Tab stop is 4
        return 4 - (column % 4);
    }

    public static int find(char c, string s, int startIndex) {
        int length = cast(int)(s.length);
        for (int i = startIndex; i < length; i++) {
            if (s[i] == c) {
                return i;
            }
        }
        return -1;
    }

    public static int findLineBreak(string s, int startIndex) {
        int length = cast(int)(s.length);
        for (int i = startIndex; i < length; i++) {
            switch (s[i]) {
                case '\n':
                case '\r':
                    return i;
                default:break;
            }
        }
        return -1;
    }

    public static bool isBlank(string s) {
        return findNonSpace(s, 0) == -1;
    }

    public static bool isLetter(string s, int index) {
        // int codePoint = Char.codePointAt(s, index);
        // return Char.isLetter(codePoint);
        import std.ascii;
        auto b = isAlpha(s.charAt(index));
        return b;
    }

    public static bool isSpaceOrTab(string s, int index) {
        if (index < s.length) {
            switch (s[index]) {
                case ' ':
                case '\t':
                    return true;
                default: break;
            }
        }
        return false;
    }

    /**
     * Prepares the input line replacing {@code \0}
     */
    public static string prepareLine(string line) {
        // Avoid building a new string in the majority of cases (no \0)
        StringBuilder sb = null;
        int length = cast(int)(line.length);
        for (int i = 0; i < length; i++) {
            char c = line[i];
            switch (c) {
                case '\0':
                    if (sb is null) {
                        sb = new StringBuilder(length);
                        sb.append(line, 0, i);
                    }
                    sb.append("\uFFFD");
                    break;
                default:
                    if (sb !is null) {
                        sb.append(c);
                    }
            }
        }

        if (sb !is null) {
            return sb.toString();
        } else {
            return line;
        }
    }

    public static int skip(char skip, string s, int startIndex, int endIndex) {
        for (int i = startIndex; i < endIndex; i++) {
            if (s[i] != skip) {
                return i;
            }
        }
        return endIndex;
    }

    public static int skipBackwards(char skip, string s, int startIndex, int lastIndex) {
        for (int i = startIndex; i >= lastIndex; i--) {
            if (s[i] != skip) {
                return i;
            }
        }
        return lastIndex - 1;
    }

    public static int skipSpaceTab(string s, int startIndex, int endIndex) {
        for (int i = startIndex; i < endIndex; i++) {
            switch (s[i]) {
                case ' ':
                case '\t':
                    break;
                default:
                    return i;
            }
        }
        return endIndex;
    }

    public static int skipSpaceTabBackwards(string s, int startIndex, int lastIndex) {
        for (int i = startIndex; i >= lastIndex; i--) {
            switch (s[i]) {
                case ' ':
                case '\t':
                    break;
                default:
                    return i;
            }
        }
        return lastIndex - 1;
    }

    private static int findNonSpace(string s, int startIndex) {
        int length = cast(int)(s.length);
        for (int i = startIndex; i < length; i++) {
            switch (s[i]) {
                case ' ':
                case '\t':
                case '\n':
                case '\u000B':
                case '\f':
                case '\r':
                    break;
                default:
                    return i;
            }
        }
        return -1;
    }
}
