module orgparser.orgparser;

import orgparser.node;

import std.range;
import std.regex;
import std.conv;


class OrgParser {
    this(string input, int pos, TodoWords todoKeys) {
	input_=input;
	pos_=pos;
	todoKeys_=todoKeys;
	heading = regex(`^(?<=\n)(\*+) (?:\s+(TODO|DONE)){0,1} (?:\s+(\[#\w\])){0,1} \s+(.*?) (?:\s+(:(?:\w|@)+)(:(?:\w|@)+)*:){0,1} [\s--\n]*`, "x");

    }
    Node parse() {
	while(!current.empty) {
	    auto c=current.front;
	    if(parseNode!"heading"())
		continue;
	    else if(parseNode!"commentLine"()) 
		continue;
	    else if(parseNode!"varAssignment"())
		continue;
	    else { // Just text
		debug(orgparser){import std.stdio; writefln("Found text");}
		if(cTextStart_ is null)
		    cTextStart_=input_.ptr;
		input_.popFront();
	    }
	}
    }
    /**
     * Parse something specified by what.
     *
     * Make sure that your regex matches from the beginning, a non
     * empty "pre" is considered invalid.
 
     * Params:
     *  what = What to parse. Must be one of the regex'es defined in this class.
     */
    bool parseNode(string what)() {
	import std.uni;
	mixin("auto res=input_.match("~what~");");
	if (!res)
	    return false;
	input_=input_[res.front.pre.length..$];
	// Ok append leading text:
	if(cTextStart_ !is null) {
	    string text=cTextStart_[0..(input_.ptr-cTextStart_)];
	    appendNode(new SimpleNode(text));
	    cTextStart_=null;
	}
	input_=input_[res.front.hit.length .. $]; // Going forward ...
	mixin("parse"~capitalizeOnly(what)~"(res.front);");
	return true;
    }
private:
    string current() @property {
	return input_[pos_ .. $];
    }
    /**
     * Append node tok to cNode_ and make it the new cNode_.
     *
     * Params:
     *  tok = The node to append and which will become the new current node.
     * Returns:
     *  The appended node for convenience.
     */
    Node appendNode(Node tok) {
	if(sNode_ is null) {
	    cNode_=tok;
	    sNode_=tok;
	}
	else {
	    cNode_.next=tok;
	    cNode_=tok;
	}
	return tok;
    }
    
    Regex!char heading;
    void parseHeading(Captures!string caps) {
    }
    static Regex!char commentLine;
    void parseCommentLine(Captures!string caps) {
	appendNode(new SimpleNode(caps.hit)).isComment=true;
    }

    static Regex!char varAssignment;
    void parseVarAssignment(Captures!string caps) {
	debug(orgparser) { import std.stdio; writefln("Found variable: %s:%s", caps["variable"], caps["value"]); }
	auto name=caps["variable"];
	auto value=caps["value"];
	cVariables_[name]=value;
	if(name=="TODO") {
	    todoKeywords_=[];
	    foreach(todo; splitter(value, regex(`\s+|(\s*\|\s*)`))) {
		if(!todo.empty)
		    todoKeywords_~=todo;
	    }
	    if(!todoKeywords_.empty) {
		auto new_heading = `^(\*+) (?:\s+(`;
		foreach(todo; todoKeywords_) 
		    new_heading ~= todo ~ "|";
		new_heading=new_heading[0..$-1];
		new_heading~=`)){0,1} (?:\s+(\[#\w\])){0,1} \s+(.*?) (?:\s+(:(?:\w|@)+)(:(?:\w|@)+)*:){0,1} [\s--\n]*`;
		heading=regex(new_heading, "x");
	    }
	}
	appendNode(new SimpleNode(caps.hit));
    }
    

    static this() {
	commentLine = regex(`^[\s--\n]*#\s.*`);
	varAssignment = regex(`^#\+(?P<variable>\w+):(?P<value>.*)`);
    }
    string input_;
    int pos_;
    immutable(char)* cTextStart_;
    Node sNode_;
    Node cNode_;
    string[string] cVariables_;
    TodoWords todoKeys_;
}

unittest {
    import std.stdio;
    auto parser = new OrgParser(`* Some heading
               # Comment!
#+TODO: NOTDONE | DONE
`);
    assert(parser.todoKeywords_==["TODO", "DONE"]);
    parser.parse();
    assert("TODO" in parser.cVariables_);
    writefln("Found TODO: %s", parser.cVariables_["TODO"]);
    writefln("Following todo keywords are active: %s", parser.todoKeywords_);
    assert(parser.cVariables_["TODO"]==" NOTDONE | DONE");
    assert(parser.todoKeywords_==["NOTDONE", "DONE"]);
    writefln("Found text: '%s'", parser.sNode_.text);
    assert(parser.sNode_.text == "* Some heading\n");
    
    assert(parser.sNode_.next.text == "               # Comment!");
    assert(parser.sNode_.next.next.text == "\n");
    assert(parser.cNode_==parser.sNode_.next.next.next);
    assert(parser.cNode_.text=="#+TODO: NOTDONE | DONE");
 
}
private:
string capitalizeOnly(string input) {
    import std.uni;
    import std.utf;
    auto cap=toUpper(input.front);
    input.popFront();
    char[4] buf;
    auto len=encode(buf, cap);
    return cast(string)(buf[0..len])~input;
}

unittest {
    assert(capitalizeOnly("alleGutenDinge")=="AlleGutenDinge");
    assert(capitalizeOnly("AlleGutenDinge")=="AlleGutenDinge");
}
