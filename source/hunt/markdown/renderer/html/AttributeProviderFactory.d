module hunt.markdown.renderer.html.AttributeProviderFactory;

import hunt.markdown.renderer.html.AttributeProvider;
import hunt.markdown.renderer.html.AttributeProviderContext;

/**
 * Factory for instantiating new attribute providers when rendering is done.
 */
public interface AttributeProviderFactory {

    /**
     * Create a new attribute provider.
     *
     * @param context for this attribute provider
     * @return an AttributeProvider
     */
    AttributeProvider create(AttributeProviderContext context);
}
