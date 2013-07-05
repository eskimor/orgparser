module orgparser.token;

import std.bitmanip;

/**
 * Input is broken up into smaller strings which have some meaning.
 * Each such string is represented by a Token object. If you have just
 * text/whitespace with no special meaning simply use the TextToken class.
 */
class Token {
   /**
    * Print this token and its children (if any) in 'org-mode' format.
    */ 
    abstract void toString(scope void delegate(const(char)[]) sink) const;

    Token next() @property {
	return next_;
    }
    Token prev() @property {
	return prev_;
    }
    /**
     * Insert the token chain tok after this token.
     *
     * tok.prev will be set to this, regardless of its prior value. 
     *
     * Returns: The tail of the inserted token for convenience.
     */
    Token insert(Token tok) 
	in { assert(tok !is null, "Inserting a null token is not supported!"); }
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
     * Remove this token from its chain.
     *
     * In case this Token is an in-between child prev.next will be set to next and next.prev to prev.
     * In case this Token is the first child prev.child will be set to next and next.prev to prev.
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

    CompositeToken isComposite() @property {
	return null;
    }

private:
    mixin(bitfields!(
	      bool, "isComment_", 1,
	      bool, "", 7
	      ));

    Token prev_;
    Token next_;
}

class TextToken : Token {
    this(string text) {
	text_=text;
    }
    override void toString(scope void delegate(const(char)[]) sink) const {
	sink(text_);
    }
private:
    string text_;
}

class CompositeToken : Token {
    override void toString(scope void delegate(const(char)[]) sink) const {
	foreach(c; children())
	    c.toString(sink);
    }
    TokenRange children() {
	return TokenRange(child_);
    }

    /**
     * The specified child will inserted as our first child.
     *
     * Unlink will be called on the to be inserted child.
     */
    void insertChild(Token child) {
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
    void appendChild(Token child) {
	if(end_) 
	    end_ = end_.insert(child);
	else {
	    child_ = end_ = child;
	    child.prev=this;
	}
    }
    void unlinkChild(Token child) 
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
	else if
	    child.unlink();
	if(child_ is null)
	    end_ = null;
    }
    override CompositeToken isComposite() @property {
	return this;
    }

private:
    Token child_;
    Token end_;
}


struct TokenRange {
    private this(Token t) {
	t_=t;
    }
    Token front() @property {
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
    Token t_;
}
