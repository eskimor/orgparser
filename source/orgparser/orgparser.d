module orgparser.orgparser;

import orgparser.token;

import std.range;
import std.regex;
import std.conv;

class OrgParser {
    this(string input) {
	input_=input;
	cVariables_["TODO"]="TODO | DONE";
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
    string input_;
    immutable(char)* cTextStart_;
    Token sToken_;
    Token cToken_;
    string[string] cVariables_;
    static Regex!char headingRE;
    
    static Regex!char commentLine;
    void parseCommentLine(Captures!string caps) {
	appendToken(new SimpleToken(caps.hit)).isComment=true;
    }

    static Regex!char varAssignment;
    void parseVarAssignment(Captures!string caps) {
	debug(orgparser) { import std.stdio; writefln("Found variable: %s:%s", caps["variable"], caps["value"]); }
	cVariables_[caps["variable"]]=caps["value"];
	appendToken(new SimpleToken(caps.hit));
    }

    static this() {
//	headingRE = regex!(`^(\*+)(\s+(\w+))?(\s+(\[#\w\]))?\s+(.*)(\s+(:\w+)(:\w+)*:)?$`, "m");
	commentLine = regex(`^[\s--\n]*#\s.*`);
	varAssignment = regex(`^#\+(?P<variable>\w+):(?P<value>.*)`);
    }
}

unittest {
    import std.stdio;
    auto parser = new OrgParser(`* Some heading
               # Comment!
#+TODO: NOTDONE | DONE
`);
    parser.parse();
    assert("TODO" in parser.cVariables_);
    writefln("Found TODO: %s", parser.cVariables_["TODO"]);
    assert(parser.cVariables_["TODO"]==" NOTDONE | DONE");
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
