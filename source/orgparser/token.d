module orgparser.token;

import std.bitmanip;

/**
 * Input is broken up into smaller strings which have some meaning.
 * Each such string is represented by a Token object. If you have just
 * text/whitespace with no special meaning simply use the SimpleToken sub-class
 */
class Token {
    abstract string text() @property;
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
    Token next_;
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
