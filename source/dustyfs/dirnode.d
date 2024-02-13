module dustyfs.dirnode;


import dustyfs.node;
import dustyfs.fs;
import std.algorithm.iteration;
import std.array;

import utils;

import dustyfs.metadata;
class DirNode : NodeWithMetadata{
    protected DustyFs parent;
    NodeStream nodeWriter;

    protected bool dirty = false;
    bool isDirty() => this.dirty;

    MetaMetaData[] listing = new MetaMetaData[0];

    this(DustyFs parent, uint reserveSize = 1024){
        this.parent = parent;
        this.nodeWriter = new NodeStream(parent, reserveSize);

        this.dirty = true;
    }
    this(DustyFs parent, uint offset, uint endingOffset){
        this.parent = parent;
        this.nodeWriter = new NodeStream(parent, offset, endingOffset);
        nodeWriter.seek(1);
        foreach(_ ; 0..nodeWriter.readInt!uint())
            this.listing~=nodeWriter.readMetaMetadata();


        this.dirty = false;
    }
    void write(){
        nodeWriter.seek(0);
        nodeWriter.writeInt!ubyte(NodeType.Directory);
        nodeWriter.writeInt!uint(cast(uint) listing.length);

        foreach (ref MetaMetaData element ; listing)
            nodeWriter.writeMetaMetadata(element);

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
        child.write();
        addNode(MetaMetaData(NodeType.Directory, n, 0, child.nodeWriter.initialOffset));
    }
    void touch(string n, int prealloc = 128){
        assert(isValidFileName(n));

    }




}