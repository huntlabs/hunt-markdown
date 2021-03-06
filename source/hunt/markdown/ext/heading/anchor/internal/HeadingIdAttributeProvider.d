module hunt.markdown.ext.heading.anchor.internal.HeadingIdAttributeProvider;

import hunt.markdown.ext.heading.anchor.IdGenerator;
import hunt.markdown.renderer.html.AttributeProvider;
import hunt.markdown.node.Node;
import hunt.markdown.node.Heading;
import hunt.markdown.node.Code;
import hunt.markdown.node.Text;
import hunt.markdown.node.AbstractVisitor;

import hunt.collection.ArrayList;
import hunt.collection.List;
import hunt.collection.Map;

import std.string;

class HeadingIdAttributeProvider : AttributeProvider {

    private IdGenerator idGenerator;

    private this(string defaultId, string prefix, string suffix) {
        idGenerator = IdGenerator.builder()
                .defaultId(defaultId)
                .prefix(prefix)
                .suffix(suffix)
                .build();
    }

    public static HeadingIdAttributeProvider create(string defaultId, string prefix, string suffix) {
        return new HeadingIdAttributeProvider(defaultId, prefix, suffix);
    }

    override public void setAttributes(Node node, string tagName, Map!(string, string) attributes) {

        if (cast(Heading)node !is null) {

            List!(string) wordList = new ArrayList!(string)();

            node.accept(new class AbstractVisitor {
                override public void visit(Text text) {
                    wordList.add(text.getLiteral());
                }

                override public void visit(Code code) {
                    wordList.add(code.getLiteral());
                }
            });

            string finalstring = "";
            foreach (string word ; wordList) {
                finalstring ~= word;
            }
            finalstring = strip(finalstring).toLower();

            attributes.put("id", idGenerator.generateId(finalstring));
        }
    }
}
