module hunt.markdown.parser.delimiter.DelimiterRun;

/**
 * A delimiter run is one or more of the same delimiter character.
 */
public interface DelimiterRun {

    /**
     * @return whether this can open a delimiter
     */
    bool canOpen();

    /**
     * @return whether this can close a delimiter
     */
    bool canClose();

    /**
     * @return the number of characters in this delimiter run (that are left for processing)
     */
    int length();

    /**
     * @return the number of characters originally in this delimiter run; at the start of processing, this is the same
     * as {{@link #length()}}
     */
    int originalLength();
}
