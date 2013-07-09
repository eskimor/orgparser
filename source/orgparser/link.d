module orgparser.link;

import orgparser.node;
import orgparser.compositenode;
import orgparser.orgparser;

import std.range;
import std.array;

class Link : CompositeNode {
    this(string link, string description="") {
	parts_[Items.link]=link;
	parts_[Items.description]=description;
    }
    override ForwardAssignable!Node opSlice() {
	return inputRangeObject(parts_);
    }
    override void toString(scope void delegate(const(char)[]) sink, FormatSpec!char fmt) const {
	sink("[[");
	sink(link);
	sink("]");
	if(!description.empty) {
	    sink("[");
	    sink(description);
	    sink("]");
	}
	sink("]");
    }

    ref string link() {
	return parts_[Items.link];
    }
    ref string description() {
	return parts_[Items.description];
    }
private:
    enum Items { link, description };
    string[2] parts_;
}
