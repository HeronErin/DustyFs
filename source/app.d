import std.stdio;
import falloc;
import dustyfs.node;
import freck.streams.memorystream;
import freck.streams.filestream;
import utils;
import dustyfs : DustyFs;

import caiman.typecons;


void main(){
    import betterMemoryStream;

    auto m = new MemoryStream(new ubyte[0]);
    m.write([1, 2, 3, 4, 5]);
    m.getContents().writeln();

    //DustyFs dfs = new DustyFs("dustyfs.dust", true);
    //dfs.root.mkDir("Test dirr");
    //dfs.close();
    //
    //dfs = new DustyFs("dustyfs.dust", false);
    //dfs.root.listDir().writeln();
    //dfs.close();
    //auto data = new ubyte[10000];
    //auto allc = new falloc.FileAlloc(MemoryStream.fromBytes(data), true);
    //allc.alloc(100).writeln();
    //
    //allc.close();







}
