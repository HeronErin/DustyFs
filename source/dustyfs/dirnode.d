/+  This file is a part of DustyFs, a free backup utility/filesystem.

    Copyright (C) 2024 - HeronErin

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
        (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
+/
module dustyfs.dirnode;


import dustyfs.node;
import dustyfs.fs;
import dustyfs.filenode;
import std.algorithm.iteration;
import std.array;

import utils;

import dustyfs.metadata;
import std.stdio;
import std.typecons;
import abstractfs;

class DirNode : NodeWithMetadata, DirInterface{
    protected DustyFs parent;
    bool closed = false;
    uint file_ptr;
    NodeStream nodeWriter;

    protected bool dirty = false;
    bool isDirty() => this.dirty;

    MetaMetaData[] listing = new MetaMetaData[0];

    this(DustyFs parent, uint reserveSize = 128){
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

        auto count = nodeWriter.readInt!uint();
        foreach(_ ; 0..count)
            this.listing~=nodeWriter.readMetaMetadata();
        
        this.dirty = false;
    }
    void write(){
        nodeWriter.seek(0);
        nodeWriter.writeInt!ubyte(NodeType.Directory);
        nodeWriter.writeInt!uint(cast(uint) listing.length);

        // writeln("Writing dir at ", this.nodeWriter.tell(), " with ", listing.length);
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
    DirNode mkDir(string n){
        assert(isValidFileName(n));
        DirNode child = new DirNode(parent);

        child.write();

        MetaMetaData mmd;
        mmd.nodeType = NodeType.Directory;
        mmd.name = n;
        mmd.size = 0;
        mmd.ptr = child.nodeWriter.initialOffset;
        mmd.isDirty=true; // Not written yet.

        addNode(mmd);

        import dustyfs.lazyload : ResolvedLazyloadItem;
        parent.resolvableNodes[mmd.ptr] = ResolvedLazyloadItem.from(child, mmd.ptr);

        return child;
    }
    FileNode touch(string n, int prealloc = 128){
        assert(isValidFileName(n));
        FileNode file = new FileNode(parent);

        file.write();
        
        MetaMetaData mmd;
        mmd.nodeType = NodeType.File;
        mmd.name = n;
        mmd.size = 0;
        mmd.ptr = file.nodeWriter.initialOffset;
        mmd.isDirty=true; // Not written yet.

        addNode(mmd);

        import dustyfs.lazyload : ResolvedLazyloadItem;
        parent.resolvableNodes[mmd.ptr] = ResolvedLazyloadItem.from(file, mmd.ptr);
        
        return file;
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

    import dustyfs.lazyload: UnResolvedLazyloadItem;
    UnResolvedLazyloadItem[] listDir(){
        import std.algorithm.iteration;
        return listing
            .map!(metaMetaData=>UnResolvedLazyloadItem(metaMetaData.nodeType, metaMetaData.name, metaMetaData.ptr, parent))
            .array();
    }

    void tree(){
        tree(0, this);
    }
    protected void tree(int tabLevel, DirNode dir){
        foreach(ref item ; dir.listDir()){
            int temp = tabLevel;

            while (temp--) " │".write();
            writeln(" ├─" ~ item.name);
            switch (item.nodeType){
                case NodeType.Directory:
                    DirNode subDir = item.as!DirNode;
                    tree(tabLevel+1, subDir);
                    break;
                case NodeType.File:
                    break;
                default:
                    assert(0, "Invalid lazyloaded object!");
                    break;
            }
        }
    }

    Nullable!UnResolvedLazyloadItem get(string name){
        Nullable!UnResolvedLazyloadItem result;
        foreach(ref item ; listing){
            if (item.name != name) continue;
            result = UnResolvedLazyloadItem(item.nodeType, item.name, item.ptr, parent);
            break;
        }
        return result;
    } 
}