module hunt.markdown.renderer.html.HtmlRenderer;

import hunt.markdown.Extension;
import hunt.markdown.internal.renderer.NodeRendererMap;
import hunt.markdown.internal.util.Escaping;
import hunt.markdown.node.HtmlBlock;
import hunt.markdown.node.HtmlInline;
import hunt.markdown.node.Node;
import hunt.markdown.renderer.NodeRenderer;
import hunt.markdown.renderer.Renderer;
import hunt.markdown.renderer.html.HtmlWriter;
import hunt.markdown.renderer.html.AttributeProvider;
import hunt.markdown.renderer.html.AttributeProviderFactory;
import hunt.markdown.renderer.html.HtmlNodeRendererFactory;
import hunt.markdown.renderer.html.AttributeProviderContext;
import hunt.markdown.renderer.html.HtmlNodeRendererContext;

import hunt.container.ArrayList;
import hunt.container.LinkedHashMap;
import hunt.container.List;
import hunt.container.Map;
import hunt.container.Iterable;

import hunt.lang.common;

/**
 * Renders a tree of nodes to HTML.
 * <p>
 * Start with the {@link #builder} method to configure the renderer. Example:
 * <pre><code>
 * HtmlRenderer renderer = HtmlRenderer.builder().escapeHtml(true).build();
 * renderer.render(node);
 * </code></pre>
 */
class HtmlRenderer : Renderer {

    private string softbreak;
    private bool escapeHtml;
    private bool percentEncodeUrls;
    private List!(AttributeProviderFactory) attributeProviderFactories;
    private List!(HtmlNodeRendererFactory) nodeRendererFactories;

    private this(Builder builder) {
        this.softbreak = builder.softbreak;
        this.escapeHtml = builder.escapeHtml;
        this.percentEncodeUrls = builder.percentEncodeUrls;
        this.attributeProviderFactories = new ArrayList!AttributeProviderFactory(builder.attributeProviderFactories);

        this.nodeRendererFactories = new ArrayList!HtmlNodeRendererFactory(builder.nodeRendererFactories.size() + 1);
        this.nodeRendererFactories.addAll(builder.nodeRendererFactories);
        // Add as last. This means clients can override the rendering of core nodes if they want.
        this.nodeRendererFactories.add(new class HtmlNodeRendererFactory {
            override public NodeRenderer create(HtmlNodeRendererContext context) {
                return new CoreHtmlNodeRenderer(context);
            }
        });
    }

    /**
     * Create a new builder for configuring an {@link HtmlRenderer}.
     *
     * @return a builder
     */
    public static Builder builder() {
        return new Builder();
    }

    override public void render(Node node, Appendable output) {
        RendererContext context = new RendererContext(new HtmlWriter(output));
        context.render(node);
    }

    override public string render(Node node) {
        StringBuilder sb = new StringBuilder();
        render(node, sb);
        return sb.toString();
    }

    /**
     * Builder for configuring an {@link HtmlRenderer}. See methods for default configuration.
     */
    public static class Builder {

        private string _softbreak = "\n";
        private bool _escapeHtml = false;
        private bool _percentEncodeUrls = false;
        private List!(AttributeProviderFactory) _attributeProviderFactories = new ArrayList!AttributeProviderFactory();
        private List!(HtmlNodeRendererFactory) _nodeRendererFactories = new ArrayList!HtmlNodeRendererFactory();

        /**
         * @return the configured {@link HtmlRenderer}
         */
        public HtmlRenderer build() {
            return new HtmlRenderer(this);
        }

        /**
         * The HTML to use for rendering a softbreak, defaults to {@code "\n"} (meaning the rendered result doesn't have
         * a line break).
         * <p>
         * Set it to {@code "<br>"} (or {@code "<br />"} to make them hard breaks.
         * <p>
         * Set it to {@code " "} to ignore line wrapping in the source.
         *
         * @param softbreak HTML for softbreak
         * @return {@code this}
         */
        public Builder softbreak(string softbreak) {
            this._softbreak = softbreak;
            return this;
        }

        /**
         * Whether {@link HtmlInline} and {@link HtmlBlock} should be escaped, defaults to {@code false}.
         * <p>
         * Note that {@link HtmlInline} is only a tag itself, not the text between an opening tag and a closing tag. So
         * markup in the text will be parsed as normal and is not affected by this option.
         *
         * @param escapeHtml true for escaping, false for preserving raw HTML
         * @return {@code this}
         */
        public Builder escapeHtml(bool escapeHtml) {
            this._escapeHtml = escapeHtml;
            return this;
        }

        /**
         * Whether URLs of link or images should be percent-encoded, defaults to {@code false}.
         * <p>
         * If enabled, the following is done:
         * <ul>
         * <li>Existing percent-encoded parts are preserved (e.g. "%20" is kept as "%20")</li>
         * <li>Reserved characters such as "/" are preserved, except for "[" and "]" (see encodeURI in JS)</li>
         * <li>Unreserved characters such as "a" are preserved</li>
         * <li>Other characters such umlauts are percent-encoded</li>
         * </ul>
         *
         * @param percentEncodeUrls true to percent-encode, false for leaving as-is
         * @return {@code this}
         */
        public Builder percentEncodeUrls(bool percentEncodeUrls) {
            this._percentEncodeUrls = percentEncodeUrls;
            return this;
        }

        /**
         * Add a factory for an attribute provider for adding/changing HTML attributes to the rendered tags.
         *
         * @param attributeProviderFactory the attribute provider factory to add
         * @return {@code this}
         */
        public Builder attributeProviderFactory(AttributeProviderFactory attributeProviderFactory) {
            this._attributeProviderFactories.add(attributeProviderFactory);
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
        public Builder nodeRendererFactory(HtmlNodeRendererFactory nodeRendererFactory) {
            this._nodeRendererFactories.add(nodeRendererFactory);
            return this;
        }

        /**
         * @param extensions extensions to use on this HTML renderer
         * @return {@code this}
         */
        public Builder extensions(Iterable!Extension extensions) {
            foreach (Extension extension ; extensions) {
                if (cast(HtmlRendererExtension)extension !is null) {
                    HtmlRendererExtension htmlRendererExtension = cast(HtmlRendererExtension) extension;
                    htmlRendererExtension.extend(this);
                }
            }
            return this;
        }
    }

    /**
     * Extension for {@link HtmlRenderer}.
     */
    public interface HtmlRendererExtension : Extension {
        void extend(Builder rendererBuilder);
    }

    private class RendererContext : HtmlNodeRendererContext, AttributeProviderContext {

        private HtmlWriter _htmlWriter;
        private List!(AttributeProvider) _attributeProviders;
        private NodeRendererMap _nodeRendererMap = new NodeRendererMap();

        private this(HtmlWriter htmlWriter) {
            this._htmlWriter = htmlWriter;

            _attributeProviders = new ArrayList!AttributeProvider(attributeProviderFactories.size());
            foreach (AttributeProviderFactory attributeProviderFactory ; attributeProviderFactories) {
                _attributeProviders.add(attributeProviderFactory.create(this));
            }

            // The first node renderer for a node type "wins".
            for (int i = nodeRendererFactories.size() - 1; i >= 0; i--) {
                HtmlNodeRendererFactory nodeRendererFactory = nodeRendererFactories.get(i);
                NodeRenderer nodeRenderer = nodeRendererFactory.create(this);
                nodeRendererMap.add(nodeRenderer);
            }
        }

        override public bool shouldEscapeHtml() {
            return escapeHtml;
        }

        public string encodeUrl(string url) {
            if (percentEncodeUrls) {
                return Escaping.percentEncodeUrl(url);
            } else {
                return url;
            }
        }

        public Map!(string, string) extendAttributes(Node node, string tagName, Map!(string, string) attributes) {
            Map!(string, string) attrs = new LinkedHashMap!(string, string)(attributes);
            setCustomAttributes(node, tagName, attrs);
            return attrs;
        }

        override public HtmlWriter getWriter() {
            return htmlWriter;
        }

        public string getSoftbreak() {
            return softbreak;
        }

        public void render(Node node) {
            nodeRendererMap.render(node);
        }

        private void setCustomAttributes(Node node, string tagName, Map!(string, string) attrs) {
            foreach (AttributeProvider attributeProvider ; attributeProviders) {
                attributeProvider.setAttributes(node, tagName, attrs);
            }
        }
    }
}
