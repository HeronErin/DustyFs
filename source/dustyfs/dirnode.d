module dustyfs.dirnode;


import dustyfs.node;
import dustyfs.fs;
import std.algorithm.iteration;
import std.array;

import utils;

import dustyfs.metadata;
class DirNode : NodeWithMetadata{
    protected DustyFs parent;
    bool closed = false;
    uint file_ptr;
    NodeStream nodeWriter;

    protected bool dirty = false;
    bool isDirty() => this.dirty;

    MetaMetaData[] listing = new MetaMetaData[0];

    this(DustyFs parent, uint reserveSize = 1024){
        this.parent = parent;
        this.nodeWriter = new NodeStream(parent.allocator, reserveSize);
        this.file_ptr = nodeWriter.initialOffset;

        this.dirty = true;
    }
    this(uint offset, DustyFs parent){
        this.parent = parent;
        this.nodeWriter = new NodeStream(offset, parent.allocator);
        this.file_ptr = offset;
        nodeWriter.seek(0);
        assert(nodeWriter.readInt!ubyte == NodeType.Directory, "Attempted to load something other than a directory as a directory!");

        foreach(_ ; 0..nodeWriter.readInt!uint())
            this.listing~=nodeWriter.readMetaMetadata();
        import std.stdio;
        writeln("Listing loaded with ", listing.length, " items");

        this.dirty = false;
    }
    void write(){
        nodeWriter.seek(0);
        nodeWriter.writeInt!ubyte(NodeType.Directory);
        nodeWriter.writeInt!uint(cast(uint) listing.length);

        foreach (ref MetaMetaData element ; listing)
            nodeWriter.writeMetaMetadata(element);
        this.dirty = false;

    }

    void addNode(MetaMetaData meta){
        assert(isValidFileName(meta.name));
        foreach(ref m ; listing)
            assert(m.name != meta.name, "Name aleady exists");
        listing~=meta;
        this.dirty=true;
    }
    void mkDir(string n){
        assert(isValidFileName(n));
        DirNode child = new DirNode(parent);
        scope (exit) child.close();

        child.write();

        MetaMetaData mmd;
        mmd.nodeType = NodeType.Directory;
        mmd.name = "Hello world";
        mmd.size = 0;
        mmd.ptr = child.nodeWriter.initialOffset;
        mmd.isDirty=true; // Not written yet.

        addNode(mmd);
    }
    void touch(string n, int prealloc = 128){
        assert(isValidFileName(n));
    }

    void close(){
        if (this.closed) return;
        if (parent.closed) assert(0, "A Dirnode must never outlive the DustyFs it is a child of. Please use .close()");
        this.closed = true;

        if (this.dirty)
            this.write();


        this.nodeWriter.close();
    }
    ~this(){
        this.close();
    }

    auto listDir(){
        return listing;
    }





}