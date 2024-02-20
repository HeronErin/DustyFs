/+  This file is a part of DustyFs, a free backup utility/filesystem.

    Copyright (C) 2024  HeronErin

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
    FileStream fileStream = null;
    DirNode root;



    this(string path, bool doInit=false){
        fileStream=new FileStream(path, doInit ? "w+b" : "r+b");
        this.allocator = new falloc.FileAlloc(fileStream, doInit);
        if (doInit){
            root = new DirNode(this, 5);
            assert(ROOT_NODE_OFFSET == root.file_ptr, "Root node allocation seems to be incorrect!");
        }else{
            root = new DirNode(ROOT_NODE_OFFSET, this);
        }
    }
    this(StreamInterface file, bool doInit=false){
        this.allocator = new falloc.FileAlloc(file, doInit);
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

        //if (fileStream is null) return;
        //"Closing file".writeln();
        //fileStream.destroy();
    }
}

