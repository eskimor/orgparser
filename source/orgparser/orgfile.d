module orgparser.orfile;

import orgparser.node;
import orgparser.orgparser;

import std.typecons;

class OrgFile {
    this(string data, int pos=0) {
	auto parser=scoped!OrgParser(data, pos);
	content_=parser.parse();
	while(pos<data.length) {
	}
    }
private:
    Node content_;
}


