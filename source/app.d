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
    scope(exit) dfs.close();

    
    dfs.root.mkDir("Test data");
    dfs.root.listDir()[0].resolve.as!DirNode.writeln;










}
