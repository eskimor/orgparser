import std.stdio;
import std.array;
import std.range;
import std.regex;
void printMatches(RT)(const(char)[] text, RT regex) {
    auto res=match(text, regex);
    if(!res) {
	writeln("No match!");
	return;
    }
    int i=0;
    foreach(cap; res.captures) {
	writefln("Captures[%s]: %s", i, cap);
	i++;
    }
}
void main() {
    auto commentLine = regex(`^\s*#\s.*`);
    assert(match("    \t    # Hello", commentLine));
    auto res=match("Hallo\n", regex(".*$", "m"));
    assert(res.front.post=="", "Hmm, post is: '"~res.front.post~"'!");
    //auto headingRE = regex(`^(\*+)(\s+(\w+)){1}(\s+(\[#\w\])){1}\s+(.*)(\s+(:\w+)(:\w+)*:){1}\s*$`, "m");
    auto headingRE = regex(`^(\*+) (?:\s+(\w+)){0,1} (?:\s+(\[#\w\])){0,1} \s+(.*?) (?:\s+(:(?:\w|@)+)(:(?:\w|@)+)*:){0,1} \s*$`, "mx");
    string[] inputs=[
	"*        \tTest",
	"*TODO \t Test",
	"* TODO [#A] Test",
	"*** TODO [#B] Test\t \t :@tag1:tag2:tag3:",
	"**** TODO    Test\t \t :@tag1:tag2:tag3",
	"**** TODO    Test\t \t :@tag1:tag2:tag3:"
	];
    foreach(i; inputs) {
	writeln("Matches for: ", i);
	printMatches(i, headingRE);
    }
}
