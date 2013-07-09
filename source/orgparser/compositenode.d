module orgparser.compositenode;

import orgparser.node;

import std.range;
import std.algorithm;

class CompositeNode : Node {
   override void toString(scope void delegate(const(char)[]) sink, FormatSpec!char fmt) const {
       foreach(c; this[].filter!(c => c !is null))
	   c.toString(sink, fmt);
   }
   
   override CompositeNode isComposite() @property {
       return this;
   }

   /**
    * Range for iterating over the nodes children.
    */
   abstract ForwardAssignable!Node opSlice();
}
