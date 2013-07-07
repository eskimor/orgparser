module orgparser.innertext;

import orgparser.node;
import orgparser.orgparser;

class InnerText : Node {
    static InnerText parse(OrgParser parser, dchar until='\n') {
    }
    abstract void toString(scope void delegate(const(char)[]) sink, FormatSpec!char fmt) const;

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


