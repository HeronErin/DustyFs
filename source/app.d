import std.stdio;
import falloc;
import freck.streams.filestream;
import utils;
import dustyfs : DustyFs;



void main(){
    fromVarInt!ubyte(toVarInt!ushort(258)).writeln();
    //auto allocator = new DustyFs("fs.dust", true);
    //allocator.alloc(100).writeln();







}
