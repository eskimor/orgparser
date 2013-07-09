module orgparser.innertext;

import orgparser.node;
import orgparser.orgparser;
import orgparser.compositenode;

class InnerText : CompositeNode {
    static InnerText parse(OrgParser parser) {
    }
    abstract void toString(scope void delegate(const(char)[]) sink, FormatSpec!char fmt) const;

    override ForwardAssignable!Node opSlice() {
    }
private:

}


class SimpleText : InnerText {
    this(string text) {
	   text_=text;
    }
    override void toString(scope void delegate(const(char)[]) sink, FormatSpec!char fmt) const {
	sink(text_);
    }
private:
    string text_;
}


