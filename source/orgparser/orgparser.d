module orgparser.orgparser;

import orgparser.node;
import orgparser.innertext;
import orgparser.orgcontext;

import std.range;
import std.regex;
import std.conv;


class OrgParser {
    
    this(string input, int pos=0) {
	input_=input;
	pos_=pos;
	todoKeys_=todoKeys;
	heading = regex(`^(?<=\n)(\*+) (?:\s+(TODO|DONE)){0,1} (?:\s+(\[#\w\])){0,1} \s+(.*?) (?:\s+(:(?:\w|@)+)(:(?:\w|@)+)*:){0,1} [\s--\n]*`, "x");

    }
    /**
     * Apply regular expression at pos and returns SimpleText matching it.
     *
     * The provided regular expression must match from the beginning
     * or not at all. (Put a leading ^ to ensure this.
     */
    SimpleText regexParse(Regex!char r) {
	auto current=data[pos..$];
	import std.regex;
	auto res=current.match(r);
	if(!res)
	    return null;
	auto caps=res.captures;
	assert(caps.pre.empty, "The regular expression has to match from the beginning!");
	pos_+=caps.front.length;
	return new SimpleText(res.captures.front);
    }
    unittest {
	auto text="  \tHello";
	auto parser=new OrgParser(text);
	auto innerwhite=regex(`^( |\t)+`);
	auto res=parser.regexParse(innerwhite);
	assert(res && res.toString=="  \t");
	assert(parser.current=="Hello");
	parser.input_="Hello you!";
	parser.pos_=0;
	res=parser.regexParse(innerwhite);
	assert(pos_==0 && res is null);
    }

    /**
     * Check whether there is a heading at pos and what level it is.
     *
     * Returns:
     *   0 if it is no heading otherwise its level (1 to n).
     */
    int isHeadingLevel() {
	if(pos_!=0 && input_[pos_-1].front!='\n')
	    return 0;
	int count;
	string current=this.current;
	int count=0;
	while(!current.empty && current.front=='*') {
	    count++;
	    current.popFront();
	}
	if(current.empty || (current.front!=' ' && current.front!='\t'))
	    return 0;
	return count;
    }

    /**
     * Same as isHeadingLevel, but advances pos.
     */
    int parseHeadingLevel() {
	int res=isHeadingLevel();
	pos_+=res;
    }

    /**
     * If there is a valid todo keyword according to context it is returned.
     *
     * Otherwise null is returned. pos gets advanced accordingly.
     */
    SimpleText parseTodo() {
	import std.algorithm;
	string found=[];
	foreach(todo; context.todoWords.words) {
	    if(current.startsWith(todo)) {
		found=todo;
		break;
	    }
	}
	if(!found)
	    return null;
	if(current[found.length..$].match(`^(\t| )`)) {
	    pos_+=found.length;
	    return new SimpleText(found);
	}
	return null;
    }

    /**
     * Parse priority and returns it as SimpleText.
     *
     * The SimpleText object will only contain the actual priority (A-Z) not [#A].
     */
    SimpleText parsePriority() {
	auto res=current.match(`^\[#([A-Z])\]`);
	if(!res)
	    return null;
	auto prio=res.captures[1];
	assert(prio.length==1, "WTF!");
	pos_+=res.captures[0].length;
	return new SimpleText(prio);
    }
    
    /**
     * The current context of the org file.
     *
     * Contains valid todo key words, priorities, variables, ...
     */
    ref OrgContext context() {
	return context_;
    }

    /**
     * Create a parser from pos until 'until'
     *
     * The part of the input that gets passed to the new parser is
     * considered consumed in this one.
     */
    OrgParser subParser(Regex!char until) {
	current.
    }
    /**
     * Prints exception with context where in the org file the error happened.
     *
     * TODO: Properly implement this, atm the call is just forwarded to std enforce.
     */
    T enforce(T)(T value, lazy const(char)[] msg = null, string file = __FILE__, size_t line = __LINE__) {
	import std.exception;
	return enforce(value, msg, file, line);
    }
private:
    string current() @property {
	return input_[pos_ .. $];
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
    OrgContext context_;
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
