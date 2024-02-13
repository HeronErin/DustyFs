module dustyfs.fs;

import freck.streams.filestream;
import freck.streams.streaminterface;

import falloc;
import dustyfs.node : NodeStream;
import dustyfs.dirnode;
import std.stdio;

class DustyFs{
    falloc.FileAlloc allocator;
    this(string path, bool doInit=false){
        this.allocator = new falloc.FileAlloc(new FileStream(path, doInit ? "w+b" : "r+b"), doInit);
        if (doInit){
            auto node = new DirNode(this, 5);
            node.mkDir("Test");
            node.write();
            node.nodeWriter.initialOffset.writeln();


        }
    }
}

