module orgparser.headline;

import orgparser.orgcontext;
import orgparser.compositenode;

import std.range;

class HeadLine : CompositeNode {
    this(OrgParser parser) {
	parser.parseLevel();
	auto ws=`^( |\t)+`;
	auto node=parser.regexParse(ws);
	parts_[0]=assert(node, "No valid heading, space missing after leading stars!");
	parts_[1]=parser.parseTodo();
	parts_[2]=parser.regexParse(ws);
	
	parts_[3]=parser.parsePriority();
	parts_[4]=parser.regexParse(ws);

	parts_[5]=
	   
	auto r=makeHeadingRegex(todoKeys);
	auto res=data[pos..$].match(r);
	foreach(i, cap; res.captures) {
	    
	}
    }
    override ForwardAssignable!Node opSlice() {
	return inputRangeObject(parts_);
    }
private:
    static int parseLevel(string data, ref int pos) pure {
	auto current=data[pos .. $];
	int count=0;
	while(!current.empty && current.front=='*')
	    count++;
	pos+=count;
	return count;
    }
private:
    enum HeadingParts {
	level,
	todo,
	priority,
	heading,
	tags
    }
    Node[] parts_;
}
private:
Regex!char makeHeadingRegex(TodoWords todoKeys) {
    auto words=todoKeys.words;
    assert(!words.empty, "todoKeys must not be empty!");
    auto word_string;
    
    foreach(todo; words) 
	word_string ~= todo ~ "|";
    word_string=word_string[0..$-1];
    auto heading = `^(\*+) ((\s+)(` ~ word_string ~ `)){0,1} ((\s+)(\[#\w\])){0,1} (\s+)(.*?) ((\s+)(:(?:\w|@)+)(:(?:\w|@)+)*:){0,1} [\s--\n]*`;
    heading=regex(new_heading, "x");
}

