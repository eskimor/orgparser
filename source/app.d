import std.stdio;

class Test {
    void toString(scope void delegate(const(char)[]) sink) const {
	sink("hello world!");
    }
}
void main()
{ 
    writeln(new Test);
}
