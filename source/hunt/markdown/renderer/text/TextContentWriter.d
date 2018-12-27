module hunt.markdown.renderer.text.TextContentWriter;

import hunt.lang.exception;
import hunt.lang.common;

class TextContentWriter {

    private Appendable buffer;

    private char lastChar;

    public this(Appendable o) {
        buffer = o;
    }

    public void whitespace() {
        if (lastChar != 0 && lastChar != ' ') {
            append(' ');
        }
    }

    public void colon() {
        if (lastChar != 0 && lastChar != ':') {
            append(':');
        }
    }

    public void line() {
        if (lastChar != 0 && lastChar != '\n') {
            append('\n');
        }
    }

    public void writeStripped(string s) {
        append(s.replaceAll("[\\r\\n\\s]+", " "));
    }

    public void write(string s) {
        append(s);
    }

    public void write(char c) {
        append(c);
    }

    private void append(string s) {
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

    private void append(char c) {
        try {
            buffer.append(c);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        lastChar = c;
    }
}
