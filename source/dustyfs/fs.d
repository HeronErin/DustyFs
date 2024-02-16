module dustyfs.fs;

import freck.streams.filestream;
import freck.streams.streaminterface;

import falloc;
import dustyfs.node : NodeStream;
import dustyfs.dirnode;
import std.stdio;


enum ROOT_NODE_OFFSET = 25;

class DustyFs{
    falloc.FileAlloc allocator;
    bool closed = false;
    DirNode root;
    this(string path, bool doInit=false){
        this.allocator = new falloc.FileAlloc(new FileStream(path, doInit ? "w+b" : "r+b"), doInit);
        if (doInit){
            root = new DirNode(this, 5);
            assert(ROOT_NODE_OFFSET == root.file_ptr, "Root node allocation seems to be incorrect!");
        }else{
            root = new DirNode(ROOT_NODE_OFFSET, this);
        }
    }
    ~this() => assert(this.closed, "DustyFs objects MUST be closed. This can be done by calling the .close function");
    void close(){
        root.close();

        this.closed = true;
        this.allocator.close();
    }
}

