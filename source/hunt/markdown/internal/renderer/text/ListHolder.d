module hunt.markdown.internal.renderer.text.ListHolder;

abstract class ListHolder {
    private __gshared string  INDENT_DEFAULT = "   ";
    private __gshared string  INDENT_EMPTY = "";

    private ListHolder parent;
    private string indent;

    this(ListHolder parent) {
        this.parent = parent;

        if (parent !is null) {
            indent = parent.indent + INDENT_DEFAULT;
        } else {
            indent = INDENT_EMPTY;
        }
    }

    public ListHolder getParent() {
        return parent;
    }

    public string getIndent() {
        return indent;
    }
}
