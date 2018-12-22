module hunt.markdown.parser.block.BlockStart;

import hunt.markdown.internal.BlockStartImpl;

import hunt.markdown.parser.block.BlockParser;

/**
 * Result object for starting parsing of a block, see static methods for constructors.
 */
abstract class BlockStart {

    protected this() {
    }

    public static BlockStart none() {
        return null;
    }

    public static BlockStart of(BlockParser blockParsers) {
        return new BlockStartImpl(blockParsers);
    }

    public abstract BlockStart atIndex(int newIndex);

    public abstract BlockStart atColumn(int newColumn);

    public abstract BlockStart replaceActiveBlockParser();

}
