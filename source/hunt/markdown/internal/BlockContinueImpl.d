module hunt.markdown.internal.BlockContinueImpl;

import hunt.markdown.parser.block.BlockContinue;

class BlockContinueImpl : BlockContinue {

    private int newIndex;
    private int newColumn;
    private bool finalize;

    public this(int newIndex, int newColumn, bool finalize) {
        this.newIndex = newIndex;
        this.newColumn = newColumn;
        this.finalize = finalize;
    }

    public int getNewIndex() {
        return newIndex;
    }

    public int getNewColumn() {
        return newColumn;
    }

    public bool isFinalize() {
        return finalize;
    }

}
