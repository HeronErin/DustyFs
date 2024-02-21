import std.stdio;
import falloc;
import dustyfs.node;
import freck.streams.memorystream;
import freck.streams.filestream;
import utils;
import dustyfs : DustyFs;

import dustyfs.lazyload;
import dustyfs.dirnode : DirNode;

void main(){
    DustyFs dfs = new DustyFs("dustyfs.dust", true);
    

    
    dfs.root.mkDir("Test data");
    DirNode dir = dfs.root.listDir()[0].as!DirNode;

    auto d3 = dir.mkDir("More test data");
    d3.mkDir("1");
    d3.mkDir("2");

    auto d4 = dir.mkDir("Yet More test data");
    d4.mkDir("a1");
    d4.mkDir("a2").mkDir("b2").mkDir("b3");
    d4.mkDir("a3");
    dfs.root.mkDir("Some non-test data");

    dfs.close();
    dfs = new DustyFs("dustyfs.dust", false);

    dfs.allocator.printAllocTree;
    "\n\n\n\n\n\n\n".writeln();
    dfs.root.tree();
    dfs.close();

}
