module hunt.markdown.node.FencedCodeBlock;


import hunt.markdown.node.Block;
import hunt.markdown.node.Visitor;

class FencedCodeBlock : Block {

    private char fenceChar;
    private int fenceLength;
    private int fenceIndent;

    private string info;
    private string literal;

    override public void accept(Visitor visitor) {
        visitor.visit(this);
    }

    public char getFenceChar() {
        return fenceChar;
    }

    public void setFenceChar(char fenceChar) {
        this.fenceChar = fenceChar;
    }

    public int getFenceLength() {
        return fenceLength;
    }

    public void setFenceLength(int fenceLength) {
        this.fenceLength = fenceLength;
    }

    public int getFenceIndent() {
        return fenceIndent;
    }

    public void setFenceIndent(int fenceIndent) {
        this.fenceIndent = fenceIndent;
    }

    public string getInfo() {
        return info;
    }

    public void setInfo(string info) {
        this.info = info;
    }

    public string getLiteral() {
        return literal;
    }

    public void setLiteral(string literal) {
        this.literal = literal;
    }
}
