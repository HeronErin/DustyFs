import std.stdio;
import falloc;
import freck.streams.filestream;
import utils;
void main()
{
	auto alloc = new falloc.FileAlloc(new FileStream("stream.txt", "w+b"), true);
	alloc.alloc(512).writeln();
	alloc.alloc(512).writeln();



}
