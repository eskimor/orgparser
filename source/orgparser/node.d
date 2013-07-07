module orgparser.node;

import std.bitmanip;

import orgparser.orgparser;

/**
 * Input is broken up into smaller strings which have some meaning.
 * Each such string is represented by a Node object. If you have just
 * text/whitespace with no special meaning simply use the TextNode class.
 */
class Node {
    static Node parse(OrgParser parser) {
    }
   /**
    * Print this node and its children (if any) in 'org-mode' format.
    *
    * fmt.width specifies how much to indent text.
    * fmd.precision specifies the current heading level. 0 = top level (no heading at all), 1 = one start, 2 = two stars, ...
    */ 
    abstract void toString(scope void delegate(const(char)[]) sink, FormatSpec!char fmt) const;

    CompositeNode isComposite() @property {
	return null;
    }

private:
    mixin(bitfields!(
	      bool, "isComment_", 1,
	      bool, "", 7
	      ));
    
}


