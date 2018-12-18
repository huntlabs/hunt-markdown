module hunt.markdown.ext.heading.anchor.HeadingAnchorExtension;

import hunt.markdown.Extension;
import hunt.markdown.ext.heading.anchor.internal.HeadingIdAttributeProvider;
import hunt.markdown.renderer.html.AttributeProvider;
import hunt.markdown.renderer.html.AttributeProviderContext;
import hunt.markdown.renderer.html.AttributeProviderFactory;
import hunt.markdown.renderer.html.HtmlRenderer;

/**
 * Extension for adding auto generated IDs to headings.
 * <p>
 * Create it with {@link #create()} or {@link #builder()} and then configure it on the
 * renderer builder ({@link HtmlRenderer.Builder#extensions(Iterable)}).
 * <p>
 * The heading text will be used to create the id. Multiple headings with the
 * same text will result in appending a hyphen and number. For example:
 * <pre><code>
 * # Heading
 * # Heading
 * </code></pre>
 * will result in
 * <pre><code>
 * &lt;h1 id="heading"&gt;Heading&lt;/h1&gt;
 * &lt;h1 id="heading-1"&gt;Heading&lt;/h1&gt;
 * </code></pre>
 *
 * @see IdGenerator the IdGenerator class if just the ID generation part is needed
 */
class HeadingAnchorExtension : HtmlRenderer.HtmlRendererExtension {

    private string defaultId;
    private string idPrefix;
    private string idSuffix;

    private this(Builder builder) {
        this.defaultId = builder.defaultId;
        this.idPrefix = builder.idPrefix;
        this.idSuffix = builder.idSuffix;
    }

    /**
     * @return the extension built with default settings
     */
    public static Extension create() {
        return new HeadingAnchorExtension(builder());
    }

    /**
     * @return a builder to configure the extension settings
     */
    public static Builder builder() {
        return new Builder();
    }

    override public void extend(HtmlRenderer.Builder rendererBuilder) {
        rendererBuilder.attributeProviderFactory(new class AttributeProviderFactory {
            override public AttributeProvider create(AttributeProviderContext context) {
                return HeadingIdAttributeProvider.create(defaultId, idPrefix, idSuffix);
            }
        });
    }

    public static class Builder {
        private string _defaultId = "id";
        private string _idPrefix = "";
        private string _idSuffix = "";

        /**
         * @param value Default value for the id to take if no generated id can be extracted. Default "id"
         * @return {@code this}
         */
        public Builder defaultId(string value) {
            this._defaultId = value;
            return this;
        }

        /**
         * @param value Set the value to be prepended to every id generated. Default ""
         * @return {@code this}
         */
        public Builder idPrefix(string value) {
            this._idPrefix = value;
            return this;
        }

        /**
         * @param value Set the value to be appended to every id generated. Default ""
         * @return {@code this}
         */
        public Builder idSuffix(string value) {
            this._idSuffix = value;
            return this;
        }

        /**
         * @return a configured extension
         */
        public Extension build() {
            return new HeadingAnchorExtension(this);
        }
    }
}
