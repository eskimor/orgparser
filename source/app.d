import std.stdio;
import std.regex;

class Test {
    void toString(scope void delegate(const(char)[]) sink) const {
	sink("hello world!");
    }
}
void main()
{
    auto res=match("\n*", `(?<=\n)\*`);
    if(res)
	writeln("Res: ", res.front.hit);
    writeln(new Test);
}
