module hunt.markdown.renderer.text.TextContentRenderer;

import hunt.markdown.Extension;
import hunt.markdown.internal.renderer.NodeRendererMap;
import hunt.markdown.node.Node;
import hunt.markdown.renderer.NodeRenderer;
import hunt.markdown.renderer.Renderer;
import hunt.markdown.renderer.text.TextContentWriter;
import hunt.markdown.renderer.text.TextContentNodeRendererFactory;
import hunt.markdown.renderer.text.TextContentNodeRendererContext;

import hunt.container.ArrayList;
import hunt.container.List;
import hunt.lang.common;

class TextContentRenderer : Renderer {

    private bool _stripNewlines;

    private List!(TextContentNodeRendererFactory) nodeRendererFactories;

    private this(Builder builder) {
        this._stripNewlines = builder.stripNewlines;

        this.nodeRendererFactories = new ArrayList!TextContentNodeRendererFactory(builder.nodeRendererFactories.size() + 1);
        this.nodeRendererFactories.addAll(builder.nodeRendererFactories);
        // Add as last. This means clients can override the rendering of core nodes if they want.
        this.nodeRendererFactories.add(new class TextContentNodeRendererFactory {
            override public NodeRenderer create(TextContentNodeRendererContext context) {
                return new CoreTextContentNodeRenderer(context);
            }
        });
    }

    /**
     * Create a new builder for configuring an {@link TextContentRenderer}.
     *
     * @return a builder
     */
    public static Builder builder() {
        return new Builder();
    }

    public void render(Node node, Appendable output) {
        RendererContext context = new RendererContext(new TextContentWriter(output));
        context.render(node);
    }

    override public string render(Node node) {
        StringBuilder sb = new StringBuilder();
        render(node, sb);
        return sb.toString();
    }

    /**
     * Builder for configuring an {@link TextContentRenderer}. See methods for default configuration.
     */
    public static class Builder {

        private bool _stripNewlines = false;
        private List!(TextContentNodeRendererFactory) nodeRendererFactories;

        this()
        {
            nodeRendererFactories = new ArrayList!TextContentNodeRendererFactory();
        }
        
        /**
         * @return the configured {@link TextContentRenderer}
         */
        public TextContentRenderer build() {
            return new TextContentRenderer(this);
        }

        /**
         * Set the value of flag for stripping new lines.
         *
         * @param stripNewlines true for stripping new lines and render text as "single line",
         *                      false for keeping all line breaks
         * @return {@code this}
         */
        public Builder stripNewlines(bool stripNewlines) {
            this._stripNewlines = stripNewlines;
            return this;
        }

        /**
         * Add a factory for instantiating a node renderer (done when rendering). This allows to override the rendering
         * of node types or define rendering for custom node types.
         * <p>
         * If multiple node renderers for the same node type are created, the one from the factory that was added first
         * "wins". (This is how the rendering for core node types can be overridden; the default rendering comes last.)
         *
         * @param nodeRendererFactory the factory for creating a node renderer
         * @return {@code this}
         */
        public Builder nodeRendererFactory(TextContentNodeRendererFactory nodeRendererFactory) {
            this.nodeRendererFactories.add(nodeRendererFactory);
            return this;
        }

        /**
         * @param extensions extensions to use on this text content renderer
         * @return {@code this}
         */
        public Builder extensions(Iterable!Extension extensions) {
            foreach (Extension extension ; extensions) {
                if (cast(TextContentRenderer)extension !is null.TextContentRendererExtension) {
                    TextContentRenderer.TextContentRendererExtension htmlRendererExtension =
                            cast(TextContentRenderer.TextContentRendererExtension) extension;
                    htmlRendererExtension.extend(this);
                }
            }
            return this;
        }
    }

    /**
     * Extension for {@link TextContentRenderer}.
     */
    public interface TextContentRendererExtension : Extension {
        void extend(TextContentRenderer.Builder rendererBuilder);
    }

    private class RendererContext : TextContentNodeRendererContext {
        private TextContentWriter textContentWriter;
        private NodeRendererMap nodeRendererMap;

        private this(TextContentWriter textContentWriter) {
            nodeRendererMap = new NodeRendererMap();
            this.textContentWriter = textContentWriter;

            // The first node renderer for a node type "wins".
            for (int i = nodeRendererFactories.size() - 1; i >= 0; i--) {
                TextContentNodeRendererFactory nodeRendererFactory = nodeRendererFactories.get(i);
                NodeRenderer nodeRenderer = nodeRendererFactory.create(this);
                nodeRendererMap.add(nodeRenderer);
            }
        }

        override public bool stripNewlines() {
            return _stripNewlines;
        }

        override public TextContentWriter getWriter() {
            return textContentWriter;
        }

        public void render(Node node) {
            nodeRendererMap.render(node);
        }
    }
}
