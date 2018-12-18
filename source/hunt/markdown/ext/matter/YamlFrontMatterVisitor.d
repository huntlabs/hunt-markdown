module hunt.markdown.ext.matter.YamlFrontMatterVisitor;

import hunt.markdown.node.AbstractVisitor;
import hunt.markdown.node.CustomNode;

import hunt.container.LinkedHashMap;
import hunt.container.List;
import hunt.container.Map;

class YamlFrontMatterVisitor : AbstractVisitor {
    private Map!(string, List!(string)) data;

    public this() {
        data = new LinkedHashMap!(string, List!(string))();
    }

    override public void visit(CustomNode customNode) {
        if (cast(YamlFrontMatterNode)customNode !is null) {
            data.put((cast(YamlFrontMatterNode) customNode).getKey(), (cast(YamlFrontMatterNode) customNode).getValues());
        } else {
            super.visit(customNode);
        }
    }

    public Map!(string, List!(string)) getData() {
        return data;
    }
}
