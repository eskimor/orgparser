module orgparser.heading;

import std.regex;

import orgparser.node;
import orgparser.orgparser;

class Heading : Node {
    /**
     * Checks whether or not there is a heading at pos, if so it is parsed.
     *
     * Returns the newly constructed org heading object or null if
     * there was no heading.
     * 
     * pos will be updated to point right behind the data.
     */
    static Heading parse(OrgParser parser) {
	if(parser.isHeadingLevel(data, pos))
	    return new OrgHeading(data[pos..$], todoKeys);
	return null;
    }
    unittest {
	assert(isHeadingLevel("*** Hello", 0)==3);
	assert(isHeadingLevel("    **** Hello", 4)==0);
	string pref=" sfk ksflalf wflawf;wa f\njfoawjfawawa\n";
	assert(isHeadingLevel(pref~"* Heading", pref.length)==1);
	assert(isHeadingLevel(pref~"*Heading", pref.length)==0);
	assert(isHeadingLevel(pref~"*\n", pref.length)==0);
	assert(isHeadingLevel(pref~"**\t    Test\n", pref.length)==2);
    }

    /**
     * Construct a heading from org input.
     *
     * pos must be the beginning of a valid heading, if you don't know
     * whether there is call parse() instead of this constructor
     * directly.
     *
     * pos will be updated to point right behind the parsed heading.
     */
    this(string data, ref int pos, TodoWords todoKeys) {
	
    }
private:
    
}

