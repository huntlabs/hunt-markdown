module hunt.markdown.ext.matter.YamlFrontMatterNode;

import hunt.markdown.node.CustomNode;

import hunt.collection.List;

class YamlFrontMatterNode : CustomNode {
    private string key;
    private List!(string) values;

    public this(string key, List!(string) values) {
        this.key = key;
        this.values = values;
    }

    public string getKey() {
        return key;
    }

    public void setKey(string key) {
        this.key = key;
    }

    public List!(string) getValues() {
        return values;
    }

    public void setValues(List!(string) values) {
        this.values = values;
    }
}
