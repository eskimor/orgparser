module orgparser.orgparser;

import orgparser.token;

import std.range;
import std.regex;
import std.conv;

class OrgParser {
    this(string input) {
	input_=input;
	todoKeywords_=["TODO", "DONE"];
	heading = regex(`^(\*+) (?:\s+(TODO|DONE)){0,1} (?:\s+(\[#\w\])){0,1} \s+(.*?) (?:\s+(:(?:\w|@)+)(:(?:\w|@)+)*:){0,1} [\s--\n]*`, "x");

    }
    void parse() {
	while(!input_.empty) {
	    auto c=input_.front;
	    if(parseToken!"commentLine"()) 
		continue;
	    else if(parseToken!"varAssignment"())
		continue;
	    else { // Just text
		debug(orgparser){import std.stdio; writefln("Found text");}
		if(cTextStart_ is null)
		    cTextStart_=input_.ptr;
		input_.popFront();
	    }
	}
    }
    unittest {
	
    }
    /**
     * Parse something specified by what.
     *
     * Make sure that your regex matches from the beginning, a non
     * empty "pre" is considered invalid.
 
     * Params:
     *  what = What to parse. Must be one of the regex'es defined in this class.
     */
    bool parseToken(string what)() {
	import std.uni;
	mixin("auto res=input_.match("~what~");");
	if (!res)
	    return false;
	assert(res.front.pre.empty, text("pre has to be empty for consumingMatch! It was: ", res.front.pre));
	// Ok append leading text:
	if(cTextStart_ !is null) {
	    string text=cTextStart_[0..(input_.ptr-cTextStart_)];
	    appendToken(new SimpleToken(text));
	    cTextStart_=null;
	}
	input_=input_[res.front.hit.length .. $]; // Going forward ...
	mixin("parse"~capitalizeOnly(what)~"(res.front);");
	return true;
    }
private:
    /**
     * Append token tok to cToken_ and make it the new cToken_.
     *
     * Params:
     *  tok = The token to append and which will become the new current token.
     * Returns:
     *  The appended token for convenience.
     */
    Token appendToken(Token tok) {
	if(sToken_ is null) {
	    cToken_=tok;
	    sToken_=tok;
	}
	else {
	    cToken_.next=tok;
	    cToken_=tok;
	}
	return tok;
    }
    
    Regex!char heading;
    void parseHeading(Captures!string caps) {
    }
    static Regex!char commentLine;
    void parseCommentLine(Captures!string caps) {
	appendToken(new SimpleToken(caps.hit)).isComment=true;
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
	appendToken(new SimpleToken(caps.hit));
    }
    

    static this() {
	commentLine = regex(`^[\s--\n]*#\s.*`);
	varAssignment = regex(`^#\+(?P<variable>\w+):(?P<value>.*)`);
    }
    string input_;
    immutable(char)* cTextStart_;
    Token sToken_;
    Token cToken_;
    string[string] cVariables_;
    string[] todoKeywords_;
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
    writefln("Found text: '%s'", parser.sToken_.text);
    assert(parser.sToken_.text == "* Some heading\n");
    
    assert(parser.sToken_.next.text == "               # Comment!");
    assert(parser.sToken_.next.next.text == "\n");
    assert(parser.cToken_==parser.sToken_.next.next.next);
    assert(parser.cToken_.text=="#+TODO: NOTDONE | DONE");
 
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
