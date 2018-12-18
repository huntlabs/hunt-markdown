module hunt.markdown.parser.PostProcessor;

import hunt.markdown.node.Node;

public interface PostProcessor {

    /**
     * @param node the node to post-process
     * @return the result of post-processing, may be a modified {@code node} argument
     */
    Node process(Node node);

}
