module hunt.markdown.internal.InlineParserImpl;

import hunt.markdown.internal.ReferenceParser;
import hunt.markdown.internal.inline.AsteriskDelimiterProcessor;
import hunt.markdown.internal.inline.UnderscoreDelimiterProcessor;
import hunt.markdown.internal.util.Escaping;
import hunt.markdown.internal.util.Html5Entities;
import hunt.markdown.internal.util.Parsing;
import hunt.markdown.node.Node;
import hunt.markdown.node.Text;
import hunt.markdown.parser.InlineParser;
import hunt.markdown.parser.delimiter.DelimiterProcessor;
import hunt.markdown.internal.Delimiter;
import hunt.markdown.internal.Bracket;

import hunt.container.Map;
import hunt.container.Set;
import hunt.container.Iterable;
import hunt.lang.character;

import std.regex;

class InlineParserImpl : InlineParser, ReferenceParser {

    private __gshared string  ESCAPED_CHAR = "\\\\" + Escaping.ESCAPABLE;
    private __gshared string  HTMLCOMMENT = "<!---->|<!--(?:-?[^>-])(?:-?[^-])*-->";
    private __gshared string  PROCESSINGINSTRUCTION = "[<][?].*?[?][>]";
    private __gshared string  DECLARATION = "<![A-Z]+\\s+[^>]*>";
    private __gshared string  CDATA = "<!\\[CDATA\\[[\\s\\S]*?\\]\\]>";
    private __gshared string  HTMLTAG = "(?:" + Parsing.OPENTAG + "|" + Parsing.CLOSETAG + "|" + HTMLCOMMENT + "|" + PROCESSINGINSTRUCTION + "|" + DECLARATION + "|" + CDATA + ")";
    private __gshared string  ENTITY = "&(?:#x[a-f0-9]{1,8}|#[0-9]{1,8}|[a-z][a-z0-9]{1,31});";
    private __gshared string  ASCII_PUNCTUATION = "!\"#\\$%&'\\(\\)\\*\\+,\\-\\./:;<=>\\?@\\[\\\\\\]\\^_`\\{\\|\\}~";

    private __gshared Regex!char PUNCTUATION;
    private __gshared Regex!char HTML_TAG;
    private __gshared Regex!char LINK_TITLE;
    private __gshared Regex!char LINK_DESTINATION_BRACES;
    private __gshared Regex!char LINK_LABEL;
    private __gshared Regex!char ESCAPABLE;
    private __gshared Regex!char ENTITY_HERE;
    private __gshared Regex!char TICKS;
    private __gshared Regex!char TICKS_HERE;
    private __gshared Regex!char EMAIL_AUTOLINK;
    private __gshared Regex!char AUTOLINK;
    private __gshared Regex!char SPNL;
    private __gshared Regex!char UNICODE_WHITESPACE_CHAR;
    private __gshared Regex!char WHITESPACE;
    private __gshared Regex!char FINAL_SPACE;
    private __gshared Regex!char LINE_END;

    private BitSet specialCharacters;
    private BitSet delimiterCharacters;
    private Map!(Character, DelimiterProcessor) delimiterProcessors;

    /**
     * Link references by ID, needs to be built up using parseReference before calling parse.
     */
    private Map!(string, Link) referenceMap = new HashMap!(string, Link)();

    private Node block;

    private string input;
    private int index;

    /**
     * Top delimiter (emphasis, strong emphasis or custom emphasis). (Brackets are on a separate stack, different
     * from the algorithm described in the spec.)
     */
    private Delimiter lastDelimiter;

    /**
     * Top opening bracket (<code>[</code> or <code>![)</code>).
     */
    private Bracket lastBracket;

    static this()
    {

        PUNCTUATION = Pattern
            .compile("^[" + ASCII_PUNCTUATION + "\\p{Pc}\\p{Pd}\\p{Pe}\\p{Pf}\\p{Pi}\\p{Po}\\p{Ps}]");

        HTML_TAG = regex('^' + HTMLTAG, Pattern.CASE_INSENSITIVE);

        LINK_TITLE = regex(
            "^(?:\"(" + ESCAPED_CHAR + "|[^\"\\x00])*\"" +
                    '|' +
                    "'(" + ESCAPED_CHAR + "|[^'\\x00])*'" +
                    '|' +
                    "\\((" + ESCAPED_CHAR + "|[^)\\x00])*\\))");

        LINK_DESTINATION_BRACES = regex("^(?:[<](?:[^<> \\t\\n\\\\]|\\\\.)*[>])");

        LINK_LABEL = regex("^\\[(?:[^\\\\\\[\\]]|\\\\.)*\\]");

        ESCAPABLE = regex('^' + Escaping.ESCAPABLE);

        ENTITY_HERE = regex('^' + ENTITY, Pattern.CASE_INSENSITIVE);

        TICKS = regex("`+");

        TICKS_HERE = regex("^`+");

        EMAIL_AUTOLINK = Pattern
            .compile("^<([a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*)>");

        AUTOLINK = Pattern
            .compile("^<[a-zA-Z][a-zA-Z0-9.+-]{1,31}:[^<>\u0000-\u0020]*>");

        SPNL = regex("^ *(?:\n *)?");

        UNICODE_WHITESPACE_CHAR = regex("^[\\p{Zs}\t\r\n\f]");

        WHITESPACE = regex("\\s+");

        FINAL_SPACE = regex(" *$");

        LINE_END = regex("^ *(?:\n|$)");
    }

    public this(List!(DelimiterProcessor) delimiterProcessors) {
        this.delimiterProcessors = calculateDelimiterProcessors(delimiterProcessors);
        this.delimiterCharacters = calculateDelimiterCharacters(this.delimiterProcessors.keySet());
        this.specialCharacters = calculateSpecialCharacters(delimiterCharacters);
    }

    public static BitSet calculateDelimiterCharacters(Set!(Character) characters) {
        BitSet bitSet = new BitSet();
        foreach (Character character ; characters) {
            bitSet.set(character);
        }
        return bitSet;
    }

    public static BitSet calculateSpecialCharacters(BitSet delimiterCharacters) {
        BitSet bitSet = new BitSet();
        bitSet.or(delimiterCharacters);
        bitSet.set('\n');
        bitSet.set('`');
        bitSet.set('[');
        bitSet.set(']');
        bitSet.set('\\');
        bitSet.set('!');
        bitSet.set('<');
        bitSet.set('&');
        return bitSet;
    }

    public static Map!(Character, DelimiterProcessor) calculateDelimiterProcessors(List!(DelimiterProcessor) delimiterProcessors) {
        Map!(Character, DelimiterProcessor) map = new HashMap!(Character, DelimiterProcessor)();
        addDelimiterProcessors(Arrays.asList!DelimiterProcessor(new AsteriskDelimiterProcessor(), new UnderscoreDelimiterProcessor()), map);
        addDelimiterProcessors(delimiterProcessors, map);
        return map;
    }

    private static void addDelimiterProcessors(Iterable!(DelimiterProcessor) delimiterProcessors, Map!(Character, DelimiterProcessor) map) {
        foreach (DelimiterProcessor delimiterProcessor ; delimiterProcessors) {
            char opening = delimiterProcessor.getOpeningCharacter();
            char closing = delimiterProcessor.getClosingCharacter();
            if (opening == closing) {
                DelimiterProcessor old = map.get(opening);
                if (old !is null && old.getOpeningCharacter() == old.getClosingCharacter()) {
                    StaggeredDelimiterProcessor s;
                    if (cast(StaggeredDelimiterProcessor)old !is null) {
                        s = cast(StaggeredDelimiterProcessor) old;
                    } else {
                        s = new StaggeredDelimiterProcessor(opening);
                        s.add(old);
                    }
                    s.add(delimiterProcessor);
                    map.put(opening, s);
                } else {
                    addDelimiterProcessorForChar(opening, delimiterProcessor, map);
                }
            } else {
                addDelimiterProcessorForChar(opening, delimiterProcessor, map);
                addDelimiterProcessorForChar(closing, delimiterProcessor, map);
            }
        }
    }

    private static void addDelimiterProcessorForChar(char delimiterChar, DelimiterProcessor toAdd, Map!(Character, DelimiterProcessor) delimiterProcessors) {
        DelimiterProcessor existing = delimiterProcessors.put(delimiterChar, toAdd);
        if (existing !is null) {
            throw new IllegalArgumentException("Delimiter processor conflict with delimiter char '" + delimiterChar + "'");
        }
    }

    /**
     * Parse content in block into inline children, using reference map to resolve references.
     */
    override public void parse(string content, Node block) {
        this.block = block;
        this.input = content.trim();
        this.index = 0;
        this.lastDelimiter = null;
        this.lastBracket = null;

        bool moreToParse;
        do {
            moreToParse = parseInline();
        } while (moreToParse);

        processDelimiters(null);
        mergeChildTextNodes(block);
    }

    /**
     * Attempt to parse a link reference, modifying the internal reference map.
     */
    override public int parseReference(string s) {
        this.input = s;
        this.index = 0;
        string dest;
        string title;
        int matchChars;
        int startIndex = index;

        // label:
        matchChars = parseLinkLabel();
        if (matchChars == 0) {
            return 0;
        }

        string rawLabel = input.substring(0, matchChars);

        // colon:
        if (peek() != ':') {
            return 0;
        }
        index++;

        // link url
        spnl();

        dest = parseLinkDestination();
        if (dest is null || dest.length() == 0) {
            return 0;
        }

        int beforeTitle = index;
        spnl();
        title = parseLinkTitle();
        if (title is null) {
            // rewind before spaces
            index = beforeTitle;
        }

        bool atLineEnd = true;
        if (index != input.length() && match(LINE_END) is null) {
            if (title is null) {
                atLineEnd = false;
            } else {
                // the potential title we found is not at the line end,
                // but it could still be a legal link reference if we
                // discard the title
                title = null;
                // rewind before spaces
                index = beforeTitle;
                // and instead check if the link URL is at the line end
                atLineEnd = match(LINE_END) !is null;
            }
        }

        if (!atLineEnd) {
            return 0;
        }

        string normalizedLabel = Escaping.normalizeReference(rawLabel);
        if (normalizedLabel.isEmpty()) {
            return 0;
        }

        if (!referenceMap.containsKey(normalizedLabel)) {
            Link link = new Link(dest, title);
            referenceMap.put(normalizedLabel, link);
        }
        return index - startIndex;
    }

    private Text appendText(string text, int beginIndex, int endIndex) {
        return appendText(text.subSequence(beginIndex, endIndex));
    }

    private Text appendText(string text) {
        Text node = new Text(text.toString());
        appendNode(node);
        return node;
    }

    private void appendNode(Node node) {
        block.appendChild(node);
    }

    /**
     * Parse the next inline element in subject, advancing input index.
     * On success, add the result to block's children and return true.
     * On failure, return false.
     */
    private bool parseInline() {
        bool res;
        char c = peek();
        if (c == '\0') {
            return false;
        }
        switch (c) {
            case '\n':
                res = parseNewline();
                break;
            case '\\':
                res = parseBackslash();
                break;
            case '`':
                res = parseBackticks();
                break;
            case '[':
                res = parseOpenBracket();
                break;
            case '!':
                res = parseBang();
                break;
            case ']':
                res = parseCloseBracket();
                break;
            case '<':
                res = parseAutolink() || parseHtmlInline();
                break;
            case '&':
                res = parseEntity();
                break;
            default:
                bool isDelimiter = delimiterCharacters.get(c);
                if (isDelimiter) {
                    DelimiterProcessor delimiterProcessor = delimiterProcessors.get(c);
                    res = parseDelimiters(delimiterProcessor, c);
                } else {
                    res = parseString();
                }
                break;
        }
        if (!res) {
            index++;
            // When we get here, it's only for a single special character that turned out to not have a special meaning.
            // So we shouldn't have a single surrogate here, hence it should be ok to turn it into a String.
            string literal = String.valueOf(c);
            appendText(literal);
        }

        return true;
    }

    /**
     * If RE matches at current index in the input, advance index and return the match; otherwise return null.
     */
    private string match(Regex!char re) {
        if (index >= input.length()) {
            return null;
        }
        Matcher matcher = re.matcher(input);
        matcher.region(index, input.length());
        bool m = matcher.find();
        if (m) {
            index = matcher.end();
            return matcher.group();
        } else {
            return null;
        }
    }

    /**
     * Returns the char at the current input index, or {@code '\0'} in case there are no more characters.
     */
    private char peek() {
        if (index < input.length()) {
            return input[index];
        } else {
            return '\0';
        }
    }

    /**
     * Parse zero or more space characters, including at most one newline.
     */
    private bool spnl() {
        match(SPNL);
        return true;
    }

    /**
     * Parse a newline. If it was preceded by two spaces, return a hard line break; otherwise a soft line break.
     */
    private bool parseNewline() {
        index++; // assume we're at a \n

        Node lastChild = block.getLastChild();
        // Check previous text for trailing spaces.
        // The "endsWith" is an optimization to avoid an RE match in the common case.
        if (lastChild !is null && cast(Text)lastChild !is null && (cast(Text) lastChild).getLiteral().endsWith(" ")) {
            Text text = cast(Text) lastChild;
            string literal = text.getLiteral();
            Matcher matcher = FINAL_SPACE.matcher(literal);
            int spaces = matcher.find() ? matcher.end() - matcher.start() : 0;
            if (spaces > 0) {
                text.setLiteral(literal.substring(0, literal.length() - spaces));
            }
            appendNode(spaces >= 2 ? new HardLineBreak() : new SoftLineBreak());
        } else {
            appendNode(new SoftLineBreak());
        }

        // gobble leading spaces in next line
        while (peek() == ' ') {
            index++;
        }
        return true;
    }

    /**
     * Parse a backslash-escaped special character, adding either the escaped  character, a hard line break
     * (if the backslash is followed by a newline), or a literal backslash to the block's children.
     */
    private bool parseBackslash() {
        index++;
        if (peek() == '\n') {
            appendNode(new HardLineBreak());
            index++;
        } else if (index < input.length() && ESCAPABLE.matcher(input.substring(index, index + 1)).matches()) {
            appendText(input, index, index + 1);
            index++;
        } else {
            appendText("\\");
        }
        return true;
    }

    /**
     * Attempt to parse backticks, adding either a backtick code span or a literal sequence of backticks.
     */
    private bool parseBackticks() {
        string ticks = match(TICKS_HERE);
        if (ticks is null) {
            return false;
        }
        int afterOpenTicks = index;
        string matched;
        while ((matched = match(TICKS)) !is null) {
            if (matched == ticks) {
                Code node = new Code();
                string content = input.substring(afterOpenTicks, index - ticks.length());
                string literal = WHITESPACE.matcher(content.trim()).replaceAll(" ");
                node.setLiteral(literal);
                appendNode(node);
                return true;
            }
        }
        // If we got here, we didn't match a closing backtick sequence.
        index = afterOpenTicks;
        appendText(ticks);
        return true;
    }

    /**
     * Attempt to parse delimiters like emphasis, strong emphasis or custom delimiters.
     */
    private bool parseDelimiters(DelimiterProcessor delimiterProcessor, char delimiterChar) {
        DelimiterData res = scanDelimiters(delimiterProcessor, delimiterChar);
        if (res is null) {
            return false;
        }
        int length = res.count;
        int startIndex = index;

        index += length;
        Text node = appendText(input, startIndex, index);

        // Add entry to stack for this opener
        lastDelimiter = new Delimiter(node, delimiterChar, res.canOpen, res.canClose, lastDelimiter);
        lastDelimiter.length = length;
        lastDelimiter.originalLength = length;
        if (lastDelimiter.previous !is null) {
            lastDelimiter.previous.next = lastDelimiter;
        }

        return true;
    }

    /**
     * Add open bracket to delimiter stack and add a text node to block's children.
     */
    private bool parseOpenBracket() {
        int startIndex = index;
        index++;

        Text node = appendText("[");

        // Add entry to stack for this opener
        addBracket(Bracket.link(node, startIndex, lastBracket, lastDelimiter));

        return true;
    }

    /**
     * If next character is [, and ! delimiter to delimiter stack and add a text node to block's children.
     * Otherwise just add a text node.
     */
    private bool parseBang() {
        int startIndex = index;
        index++;
        if (peek() == '[') {
            index++;

            Text node = appendText("![");

            // Add entry to stack for this opener
            addBracket(Bracket.image(node, startIndex + 1, lastBracket, lastDelimiter));
        } else {
            appendText("!");
        }
        return true;
    }

    /**
     * Try to match close bracket against an opening in the delimiter stack. Add either a link or image, or a
     * plain [ character, to block's children. If there is a matching delimiter, remove it from the delimiter stack.
     */
    private bool parseCloseBracket() {
        index++;
        int startIndex = index;

        // Get previous `[` or `![`
        Bracket opener = lastBracket;
        if (opener is null) {
            // No matching opener, just return a literal.
            appendText("]");
            return true;
        }

        if (!opener.allowed) {
            // Matching opener but it's not allowed, just return a literal.
            appendText("]");
            removeLastBracket();
            return true;
        }

        // Check to see if we have a link/image

        string dest = null;
        string title = null;
        bool isLinkOrImage = false;

        // Maybe a inline link like `[foo](/uri "title")`
        if (peek() == '(') {
            index++;
            spnl();
            if ((dest = parseLinkDestination()) !is null) {
                spnl();
                // title needs a whitespace before
                if (WHITESPACE.matcher(input.substring(index - 1, index)).matches()) {
                    title = parseLinkTitle();
                    spnl();
                }
                if (peek() == ')') {
                    index++;
                    isLinkOrImage = true;
                } else {
                    index = startIndex;
                }
            }
        }

        // Maybe a reference link like `[foo][bar]`, `[foo][]` or `[foo]`
        if (!isLinkOrImage) {

            // See if there's a link label like `[bar]` or `[]`
            int beforeLabel = index;
            int labelLength = parseLinkLabel();
            string r = null;
            if (labelLength > 2) {
                r = input.substring(beforeLabel, beforeLabel + labelLength);
            } else if (!opener.bracketAfter) {
                // If the second label is empty `[foo][]` or missing `[foo]`, then the first label is the reference.
                // But it can only be a reference when there's no (unescaped) bracket in it.
                // If there is, we don't even need to try to look up the reference. This is an optimization.
                r = input.substring(opener.index, startIndex);
            }

            if (r !is null) {
                Link link = referenceMap.get(Escaping.normalizeReference(r));
                if (link !is null) {
                    dest = link.getDestination();
                    title = link.getTitle();
                    isLinkOrImage = true;
                }
            }
        }

        if (isLinkOrImage) {
            // If we got here, open is a potential opener
            Node linkOrImage = opener.image ? new Image(dest, title) : new Link(dest, title);

            Node node = opener.node.getNext();
            while (node !is null) {
                Node next = node.getNext();
                linkOrImage.appendChild(node);
                node = next;
            }
            appendNode(linkOrImage);

            // Process delimiters such as emphasis inside link/image
            processDelimiters(opener.previousDelimiter);
            mergeChildTextNodes(linkOrImage);
            // We don't need the corresponding text node anymore, we turned it into a link/image node
            opener.node.unlink();
            removeLastBracket();

            // Links within links are not allowed. We found this link, so there can be no other link around it.
            if (!opener.image) {
                Bracket bracket = lastBracket;
                while (bracket !is null) {
                    if (!bracket.image) {
                        // Disallow link opener. It will still get matched, but will not result in a link.
                        bracket.allowed = false;
                    }
                    bracket = bracket.previous;
                }
            }

            return true;

        } else { // no link or image

            appendText("]");
            removeLastBracket();

            index = startIndex;
            return true;
        }
    }

    private void addBracket(Bracket bracket) {
        if (lastBracket !is null) {
            lastBracket.bracketAfter = true;
        }
        lastBracket = bracket;
    }

    private void removeLastBracket() {
        lastBracket = lastBracket.previous;
    }

    /**
     * Attempt to parse link destination, returning the string or null if no match.
     */
    private string parseLinkDestination() {
        string res = match(LINK_DESTINATION_BRACES);
        if (res !is null) { // chop off surrounding <..>:
            if (res.length() == 2) {
                return "";
            } else {
                return Escaping.unescapeString(res.substring(1, res.length() - 1));
            }
        } else {
            int startIndex = index;
            parseLinkDestinationWithBalancedParens();
            return Escaping.unescapeString(input.substring(startIndex, index));
        }
    }

    private void parseLinkDestinationWithBalancedParens() {
        int parens = 0;
        while (true) {
            char c = peek();
            switch (c) {
                case '\0':
                    return;
                case '\\':
                    // check if we have an escapable character
                    if (index + 1 < input.length() && ESCAPABLE.matcher(input.substring(index + 1, index + 2)).matches()) {
                        // skip over the escaped character (after switch)
                        index++;
                        break;
                    }
                    // otherwise, we treat this as a literal backslash
                    break;
                case '(':
                    parens++;
                    break;
                case ')':
                    if (parens == 0) {
                        return;
                    } else {
                        parens--;
                    }
                    break;
                case ' ':
                    // ASCII space
                    return;
                default:
                    // or control character
                    if (Character.isISOControl(c)) {
                        return;
                    }
            }
            index++;
        }
    }

    /**
     * Attempt to parse link title (sans quotes), returning the string or null if no match.
     */
    private string parseLinkTitle() {
        string title = match(LINK_TITLE);
        if (title !is null) {
            // chop off quotes from title and unescape:
            return Escaping.unescapeString(title.substring(1, title.length() - 1));
        } else {
            return null;
        }
    }

    /**
     * Attempt to parse a link label, returning number of characters parsed.
     */
    private int parseLinkLabel() {
        string m = match(LINK_LABEL);
        // Spec says "A link label can have at most 999 characters inside the square brackets"
        if (m is null || m.length() > 1001) {
            return 0;
        } else {
            return m.length();
        }
    }

    /**
     * Attempt to parse an autolink (URL or email in pointy brackets).
     */
    private bool parseAutolink() {
        string m;
        if ((m = match(EMAIL_AUTOLINK)) !is null) {
            string dest = m.substring(1, m.length() - 1);
            Link node = new Link("mailto:" + dest, null);
            node.appendChild(new Text(dest));
            appendNode(node);
            return true;
        } else if ((m = match(AUTOLINK)) !is null) {
            string dest = m.substring(1, m.length() - 1);
            Link node = new Link(dest, null);
            node.appendChild(new Text(dest));
            appendNode(node);
            return true;
        } else {
            return false;
        }
    }

    /**
     * Attempt to parse inline HTML.
     */
    private bool parseHtmlInline() {
        string m = match(HTML_TAG);
        if (m !is null) {
            HtmlInline node = new HtmlInline();
            node.setLiteral(m);
            appendNode(node);
            return true;
        } else {
            return false;
        }
    }

    /**
     * Attempt to parse an entity, return Entity object if successful.
     */
    private bool parseEntity() {
        string m;
        if ((m = match(ENTITY_HERE)) !is null) {
            appendText(Html5Entities.entityToString(m));
            return true;
        } else {
            return false;
        }
    }

    /**
     * Parse a run of ordinary characters, or a single character with a special meaning in markdown, as a plain string.
     */
    private bool parseString() {
        int begin = index;
        int length = input.length();
        while (index != length) {
            if (specialCharacters.get(input[index])) {
                break;
            }
            index++;
        }
        if (begin != index) {
            appendText(input, begin, index);
            return true;
        } else {
            return false;
        }
    }

    /**
     * Scan a sequence of characters with code delimiterChar, and return information about the number of delimiters
     * and whether they are positioned such that they can open and/or close emphasis or strong emphasis.
     *
     * @return information about delimiter run, or {@code null}
     */
    private DelimiterData scanDelimiters(DelimiterProcessor delimiterProcessor, char delimiterChar) {
        int startIndex = index;

        int delimiterCount = 0;
        while (peek() == delimiterChar) {
            delimiterCount++;
            index++;
        }

        if (delimiterCount < delimiterProcessor.getMinLength()) {
            index = startIndex;
            return null;
        }

        string before = startIndex == 0 ? "\n" :
                input.substring(startIndex - 1, startIndex);

        char charAfter = peek();
        string after = charAfter == '\0' ? "\n" :
                String.valueOf(charAfter);

        // We could be more lazy here, in most cases we don't need to do every match case.
        bool beforeIsPunctuation = PUNCTUATION.matcher(before).matches();
        bool beforeIsWhitespace = UNICODE_WHITESPACE_CHAR.matcher(before).matches();
        bool afterIsPunctuation = PUNCTUATION.matcher(after).matches();
        bool afterIsWhitespace = UNICODE_WHITESPACE_CHAR.matcher(after).matches();

        bool leftFlanking = !afterIsWhitespace &&
                (!afterIsPunctuation || beforeIsWhitespace || beforeIsPunctuation);
        bool rightFlanking = !beforeIsWhitespace &&
                (!beforeIsPunctuation || afterIsWhitespace || afterIsPunctuation);
        bool canOpen;
        bool canClose;
        if (delimiterChar == '_') {
            canOpen = leftFlanking && (!rightFlanking || beforeIsPunctuation);
            canClose = rightFlanking && (!leftFlanking || afterIsPunctuation);
        } else {
            canOpen = leftFlanking && delimiterChar == delimiterProcessor.getOpeningCharacter();
            canClose = rightFlanking && delimiterChar == delimiterProcessor.getClosingCharacter();
        }

        index = startIndex;
        return new DelimiterData(delimiterCount, canOpen, canClose);
    }

    private void processDelimiters(Delimiter stackBottom) {

        Map!(Character, Delimiter) openersBottom = new HashMap!(Character, Delimiter)();

        // find first closer above stackBottom:
        Delimiter closer = lastDelimiter;
        while (closer !is null && closer.previous != stackBottom) {
            closer = closer.previous;
        }
        // move forward, looking for closers, and handling each
        while (closer !is null) {
            char delimiterChar = closer.delimiterChar;

            DelimiterProcessor delimiterProcessor = delimiterProcessors.get(delimiterChar);
            if (!closer.canClose || delimiterProcessor is null) {
                closer = closer.next;
                continue;
            }

            char openingDelimiterChar = delimiterProcessor.getOpeningCharacter();

            // Found delimiter closer. Now look back for first matching opener.
            int useDelims = 0;
            bool openerFound = false;
            bool potentialOpenerFound = false;
            Delimiter opener = closer.previous;
            while (opener !is null && opener != stackBottom && opener != openersBottom.get(delimiterChar)) {
                if (opener.canOpen && opener.delimiterChar == openingDelimiterChar) {
                    potentialOpenerFound = true;
                    useDelims = delimiterProcessor.getDelimiterUse(opener, closer);
                    if (useDelims > 0) {
                        openerFound = true;
                        break;
                    }
                }
                opener = opener.previous;
            }

            if (!openerFound) {
                if (!potentialOpenerFound) {
                    // Set lower bound for future searches for openers.
                    // Only do this when we didn't even have a potential
                    // opener (one that matches the character and can open).
                    // If an opener was rejected because of the number of
                    // delimiters (e.g. because of the "multiple of 3" rule),
                    // we want to consider it next time because the number
                    // of delimiters can change as we continue processing.
                    openersBottom.put(delimiterChar, closer.previous);
                    if (!closer.canOpen) {
                        // We can remove a closer that can't be an opener,
                        // once we've seen there's no matching opener:
                        removeDelimiterKeepNode(closer);
                    }
                }
                closer = closer.next;
                continue;
            }

            Text openerNode = opener.node;
            Text closerNode = closer.node;

            // Remove number of used delimiters from stack and inline nodes.
            opener.length -= useDelims;
            closer.length -= useDelims;
            openerNode.setLiteral(
                    openerNode.getLiteral().substring(0,
                            openerNode.getLiteral().length() - useDelims));
            closerNode.setLiteral(
                    closerNode.getLiteral().substring(0,
                            closerNode.getLiteral().length() - useDelims));

            removeDelimitersBetween(opener, closer);
            // The delimiter processor can re-parent the nodes between opener and closer,
            // so make sure they're contiguous already. Exclusive because we want to keep opener/closer themselves.
            mergeTextNodesBetweenExclusive(openerNode, closerNode);
            delimiterProcessor.process(openerNode, closerNode, useDelims);

            // No delimiter characters left to process, so we can remove delimiter and the now empty node.
            if (opener.length == 0) {
                removeDelimiterAndNode(opener);
            }

            if (closer.length == 0) {
                Delimiter next = closer.next;
                removeDelimiterAndNode(closer);
                closer = next;
            }
        }

        // remove all delimiters
        while (lastDelimiter !is null && lastDelimiter != stackBottom) {
            removeDelimiterKeepNode(lastDelimiter);
        }
    }

    private void removeDelimitersBetween(Delimiter opener, Delimiter closer) {
        Delimiter delimiter = closer.previous;
        while (delimiter !is null && delimiter != opener) {
            Delimiter previousDelimiter = delimiter.previous;
            removeDelimiterKeepNode(delimiter);
            delimiter = previousDelimiter;
        }
    }

    /**
     * Remove the delimiter and the corresponding text node. For used delimiters, e.g. `*` in `*foo*`.
     */
    private void removeDelimiterAndNode(Delimiter delim) {
        Text node = delim.node;
        node.unlink();
        removeDelimiter(delim);
    }

    /**
     * Remove the delimiter but keep the corresponding node as text. For unused delimiters such as `_` in `foo_bar`.
     */
    private void removeDelimiterKeepNode(Delimiter delim) {
        removeDelimiter(delim);
    }

    private void removeDelimiter(Delimiter delim) {
        if (delim.previous !is null) {
            delim.previous.next = delim.next;
        }
        if (delim.next is null) {
            // top of stack
            lastDelimiter = delim.previous;
        } else {
            delim.next.previous = delim.previous;
        }
    }

    private void mergeTextNodesBetweenExclusive(Node fromNode, Node toNode) {
        // No nodes between them
        if (fromNode == toNode || fromNode.getNext() == toNode) {
            return;
        }

        mergeTextNodesInclusive(fromNode.getNext(), toNode.getPrevious());
    }

    private void mergeChildTextNodes(Node node) {
        // No children or just one child node, no need for merging
        if (node.getFirstChild() == node.getLastChild()) {
            return;
        }

        mergeTextNodesInclusive(node.getFirstChild(), node.getLastChild());
    }

    private void mergeTextNodesInclusive(Node fromNode, Node toNode) {
        Text first = null;
        Text last = null;
        int length = 0;

        Node node = fromNode;
        while (node !is null) {
            if (cast(Text)node !is null) {
                Text text = cast(Text) node;
                if (first is null) {
                    first = text;
                }
                length += text.getLiteral().length();
                last = text;
            } else {
                mergeIfNeeded(first, last, length);
                first = null;
                last = null;
                length = 0;
            }
            if (node == toNode) {
                break;
            }
            node = node.getNext();
        }

        mergeIfNeeded(first, last, length);
    }

    private void mergeIfNeeded(Text first, Text last, int textLength) {
        if (first !is null && last !is null && first != last) {
            StringBuilder sb = new StringBuilder(textLength);
            sb.append(first.getLiteral());
            Node node = first.getNext();
            Node stop = last.getNext();
            while (node != stop) {
                sb.append((cast(Text) node).getLiteral());
                Node unlink = node;
                node = node.getNext();
                unlink.unlink();
            }
            string literal = sb.toString();
            first.setLiteral(literal);
        }
    }

    private static class DelimiterData {

        int count;
        bool canClose;
        bool canOpen;

        this(int count, bool canOpen, bool canClose) {
            this.count = count;
            this.canOpen = canOpen;
            this.canClose = canClose;
        }
    }
}
