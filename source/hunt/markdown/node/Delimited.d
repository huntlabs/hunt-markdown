module hunt.markdown.node.Delimited;

/**
 * A node that uses delimiters in the source form (e.g. <code>*bold*</code>).
 */
public interface Delimited {

    /**
     * @return the opening (beginning) delimiter, e.g. <code>*</code>
     */
    string getOpeningDelimiter();

    /**
     * @return the closing (ending) delimiter, e.g. <code>*</code>
     */
    string getClosingDelimiter();
}
