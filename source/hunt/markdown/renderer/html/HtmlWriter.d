module hunt.markdown.renderer.html.HtmlWriter;

import hunt.markdown.internal.util.Escaping;

import hunt.Exceptions;
import hunt.util.Common;
import hunt.text.Common;
import hunt.collection.Collections;
import hunt.collection.Map;
import hunt.util.Appendable;
import hunt.markdown.internal.util.Common;

class HtmlWriter {

    mixin(MakeGlobalVar!(Map!(string, string))("NO_ATTRIBUTES",`Collections.emptyMap!(string, string)()`));


    private Appendable buffer;
    private char lastChar = 0;

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
            foreach (string k ,string v ; attrs) {
                append(" ");
                append(Escaping.escapeHtml(k, true));
                append("=\"");
                append(Escaping.escapeHtml(v, true));
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
        int length = cast(int)(s.length);
        if (length != 0) {
            lastChar = s.charAt(length - 1);
        }
    }
}
