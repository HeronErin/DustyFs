module dustyfs.fs;

import freck.streams.filestream;
import freck.streams.streaminterface;

import falloc;
import dustyfs.node : NodeStream;
import std.stdio;

class DustyFs{
    falloc.FileAlloc allocator;
    this(string path, bool doInit=false){
        this.allocator = new falloc.FileAlloc(new FileStream(path, doInit ? "w+b" : "r+b"), doInit);
        if (doInit){
            NodeStream node = new NodeStream(this, 5);
            node.seek(0);
            node.write(cast(ubyte[]) "1234");
            node.seek(2, Seek.cur);
            node.write('%');
            node.write(cast(ubyte[]) "123456789");
            node.seek(0);
                (cast(string)node.read(50)).writeln();

        }
    }
}

