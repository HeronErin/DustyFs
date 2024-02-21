import std.stdio;
import falloc;
import dustyfs.node;
import freck.streams.memorystream;
import freck.streams.filestream;
import utils;
import dustyfs : DustyFs;

import dustyfs.lazyload;
import dustyfs.dirnode : DirNode;
import dustyfs.filenode : FileNode;

void main(){
    DustyFs dfs = new DustyFs("dustyfs.dust", true);
    scope (exit) dfs.close();

    FileNode file = dfs.root.touch("test");
    auto f = file.open();
    f.writeInt(12);
    f.write(cast(ubyte[])"This is some test text");
    f.seek(0);
    f.readInt!int().writeln();
    (cast(string)f.read(25)).writeln();
    
    dfs.allocator.printAllocTree();

}
