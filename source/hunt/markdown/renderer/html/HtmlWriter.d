module hunt.markdown.renderer.html.HtmlWriter;

import hunt.markdown.internal.util.Escaping;

import hunt.Exceptions;
import hunt.util.Common;

import hunt.collection.Collections;
import hunt.collection.Map;

class HtmlWriter {

    private static Map!(string, string) NO_ATTRIBUTES;

    private Appendable buffer;
    private char lastChar = 0;

    static this()
    {
        NO_ATTRIBUTES = Collections.emptyMap!(string, string)();
    }

    this(Appendable o) {
        this.buffer = o;
    }

    public void raw(string s) {
        append(s);
    }

    public void text(string text) {
        append(Escaping.escapeHtml(text, false));
    }

    public void tag(string name) {
        tag(name, NO_ATTRIBUTES);
    }

    public void tag(string name, Map!(string, string) attrs) {
        tag(name, attrs, false);
    }

    public void tag(string name, Map!(string, string) attrs, bool voidElement) {
        append("<");
        append(name);
        if (attrs !is null && !attrs.isEmpty()) {
            foreach (Map.Entry!(string, string) attrib ; attrs.entrySet()) {
                append(" ");
                append(Escaping.escapeHtml(attrib.getKey(), true));
                append("=\"");
                append(Escaping.escapeHtml(attrib.getValue(), true));
                append("\"");
            }
        }
        if (voidElement) {
            append(" /");
        }

        append(">");
    }

    public void line() {
        if (lastChar != 0 && lastChar != '\n') {
            append("\n");
        }
    }

    protected void append(string s) {
        try {
            buffer.append(s);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        int length = s.length;
        if (length != 0) {
            lastChar = s.charAt(length - 1);
        }
    }
}
