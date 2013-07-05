module orgparser.token;

import std.bitmanip;

/**
 * Input is broken up into smaller strings which have some meaning.
 * Each such string is represented by a Token object. If you have just
 * text/whitespace with no special meaning simply use the SimpleToken sub-class
 */
class Token {
    /**
     * Create a new token, which is either a leaf node or a parent node.
     *
     * If you pass a string as content, it becomes a leaf node, if you pass a Token it is a parent node.
     */
    this(ContentType) (Token prev, ContentType content) if(is(ContentType : string) || is(ContentType : Token)
    in {
	assert(prev !is null);
    }
    {
	prev.next_=this;
	prev_=prev;
	content=text;
    }
    this(Token prev, Token child) {
    }
    void toString(scope void delegate(const(char)[]) sink) const {
	if(isParent_)
	    foreach(c
    }

    Token next() @property {
	return next_;
    }
    void next(Token tok) @property {
	next_=tok;
    }
    mixin(bitfields!(
	      bool, "isComment", 1,
	      bool, "", 7
	      ));
private:
    void content(string text) @property {
	isParent_=false;
	content_.text=text;
    }
    void content(Token child) @property {
	isParent_=true;
	content_.child=child;
    }

    mixin(bitfiels!(
	      bool , "isParent_", 1,
	      bool, "", 7
	      ));

    Token prev_;
    Token next_;
    union Content {
	Token child;
	string text;
    }
    Content content_;
}

class SimpleToken : Token {
    this(string text) {
	text_=text;
    }
    override string text() @property {
	return text_;
    }
private:
    string text_;
}

class Variable : Token {
    override string text() @property {
	return "";
    }
	
}
