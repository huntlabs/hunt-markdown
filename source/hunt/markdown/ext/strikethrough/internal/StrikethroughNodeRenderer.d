module hunt.markdown.ext.gfm.strikethrough.internal.StrikethroughNodeRenderer;

import hunt.markdown.ext.gfm.strikethrough.Strikethrough;
import hunt.markdown.node.Node;
import hunt.markdown.renderer.NodeRenderer;

import hunt.container.Collections;
import hunt.container.Set;

abstract class StrikethroughNodeRenderer : NodeRenderer {

    public Set!(TypeInfo_Class) getNodeTypes() {
        return Collections.singleton!(TypeInfo_Class)(typeid(Strikethrough));
    }
}
