module hunt.markdown.parser.block.BlockContinue;

import hunt.markdown.internal.BlockContinueImpl;

/**
 * Result object for continuing parsing of a block, see static methods for constructors.
 */
class BlockContinue {

    protected this() {
    }

    public static BlockContinue none() {
        return null;
    }

    public static BlockContinue atIndex(int newIndex) {
        return new BlockContinueImpl(newIndex, -1, false);
    }

    public static BlockContinue atColumn(int newColumn) {
        return new BlockContinueImpl(-1, newColumn, false);
    }

    public static BlockContinue finished() {
        return new BlockContinueImpl(-1, -1, true);
    }

}
