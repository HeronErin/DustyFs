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
module dustyfs.filenode;

import dustyfs.node;
import dustyfs.fs;
import std.algorithm.iteration;
import std.array;

import utils;

import dustyfs.metadata;
import std.stdio;

import freck.streams.streaminterface;

enum SIZE_OF_DFILE_HEADER = 1;

import std.string : StringException;

class DFile : StreamInterface{
    FileNode parent;
    NodeStream nodeWriter;
    this(FileNode parent, NodeStream nodeWriter){
        this.parent=parent;
        this.nodeWriter=nodeWriter;
    }

    void setEndian(Endian e) => nodeWriter.setEndian(e);
    Endian getEndian() => nodeWriter.getEndian();
    ssize_t length() => nodeWriter.length()-SIZE_OF_DFILE_HEADER;

    
    bool isEmpty() => nodeWriter.isEmpty();
    bool isSeekable() => nodeWriter.isSeekable();
    bool isWritable() => nodeWriter.isWritable();
    bool isReadable() => nodeWriter.isReadable();

    void write(in ubyte b)=> nodeWriter.write(b);
    void write(in ubyte[] b)=> nodeWriter.write(b);
    ubyte read() => nodeWriter.read();
    ubyte[] read(in ulong n) => nodeWriter.read(n);
    
    ulong tell() => nodeWriter.tell()-SIZE_OF_DFILE_HEADER;
    ubyte[] getContents(){
        nodeWriter.seek(SIZE_OF_DFILE_HEADER);
        return nodeWriter.read(this.length);
    }
    ulong seek(in long pos, in Seek origin = Seek.set){
        switch (origin){
            case Seek.set:
                return nodeWriter.seek(pos+SIZE_OF_DFILE_HEADER);
            default:
                return nodeWriter.seek(pos, origin);
        }
        assert(0);
    }

    string getMetadata(string key) => throw new StringException("Not a supported operation.");

    

}

class FileNode : NodeWithMetadata{
    protected DustyFs parent;
    protected bool dirty = false;
    bool closed = false;
    uint file_ptr;
    bool isDirty() => this.dirty;
    
    NodeStream nodeWriter;

    void write(){
        nodeWriter.seek(0);
        nodeWriter.writeInt!ubyte(NodeType.File);
        this.dirty = false;
    }

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
        assert(nodeWriter.readInt!ubyte == NodeType.File, "Attempted to load something other than a file as a file!");
        
        this.dirty = false;
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

    DFile open() => new DFile(this, this.nodeWriter);

}