module hunt.markdown.internal.inline.UnderscoreDelimiterProcessor;

import hunt.markdown.internal.inline.EmphasisDelimiterProcessor;

class UnderscoreDelimiterProcessor : EmphasisDelimiterProcessor {

    public this() {
        super('_');
    }
}
