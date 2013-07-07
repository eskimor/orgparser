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

    Node next() @property {
	return next_;
    }
    Node prev() @property {
	return prev_;
    }
    /**
     * Insert the node chain tok after this node.
     *
     * tok.prev will be set to this, regardless of its prior value. 
     *
     * Returns: The tail of the inserted node for convenience.
     */
    Node insert(Node tok) 
	in { assert(tok !is null, "Inserting a null node is not supported!"); }
	{
	auto oldN=next;
	next_=tok;
	auto t = tok;
	while(t.next)
	    t = t.next;

	tok.prev_=this;
	t.next_=oldN;
	return t;
    }
    
    /**
     * Remove this node from its chain.
     *
     * In case this Node is an in-between child prev.next will be set to next and next.prev to prev.
     * In case this Node is the first child prev.child will be set to next and next.prev to prev.
     */
    void unlink() 
	out { assert(prev is null && next is null); } 
	{
	    auto comp=prev.isComposite;
	    if(comp && comp.child==this) 
		comp.child_=next;
	    else if(prev)
		prev.next_=next;
	    if(next_)
		next_.prev_=prev;
	    prev_=null;
	    next_=null;
	}

    CompositeNode isComposite() @property {
	return null;
    }

private:
    mixin(bitfields!(
	      bool, "isComment_", 1,
	      bool, "", 7
	      ));
    
    Node prev_;
    Node next_;
}

class CompositeNode : Node {
    override void toString(scope void delegate(const(char)[]) sink) const {
	foreach(c; children())
	    c.toString(sink);
    }
    NodeRange children() {
	return NodeRange(child_);
    }

    /**
     * The specified child will inserted as our first child.
     *
     */
    void insertChild(Node child) {
	auto oc=child_;
	oc.prev_=null;
	child_=child;
	child_.prev=this;
	auto tn = child_;
	while (tn.next)
	    tn_ = tn.next;
	if(oc)
	    tn_.insert(oc);
	else
	    end_=tn_;
    }
    void appendChild(Node child) {
	if(end_) 
	    end_ = end_.insert(child);
	else {
	    child_ = end_ = child;
	    child.prev=this;
	}
    }
    void unlinkChild(Node child) 
	in { assert(child, "child must not be null!"); }
    {
	assert(child_, "We have no children, how do you want to unlink one?");
	if(child is child_) {
	    child_ = child.next;
	    if(child_)
		child_.prev = this;
	    else
		end_ = null;
	    child.prev = null;
	    child.next = null;
	}
	else {
	    if(child is end_) {
		end_=child.prev;
		assert(end_, "No previous element?!");
	    }
	    child.unlink();
	}
    }
    override CompositeNode isComposite() @property {
	return this;
    }

private:
    Node child_;
    Node end_;
}


struct NodeRange {
    private this(Node t) {
	t_=t;
    }
    Node front() @property {
	assert(!empty, "Check empty before bothering me!");
	return t_;
    }
    void popFront() {
	assert(!empty, "Check empty you bastard!");
	t_=t_.next;
    }
    bool empty() @property {
	return t_ !is null;
    }
private:
    Node t_;
}
