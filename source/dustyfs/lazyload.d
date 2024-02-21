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
module dustyfs.lazyload;

import dustyfs.fs;
import dustyfs.metadata;
import dustyfs.dirnode : DirNode;
import dustyfs.filenode : FileNode;
import dustyfs.node : SIZE_OF_INITIAL_NODE_HEADER;

protected pure bool isCorrect(T)(){
    return is(T == DirNode) || is(T == FileNode);
}

struct ResolvedLazyloadItem{
    NodeType type;
    uint ptr;
    void* item; // Can be anything. WARNING: CAN BE UNSAFE!!!

    T as(T)(){
        if (type == NodeType.Directory) 
            assert(
                is(T == DirNode), 
                "Error! You must use the correct type for resolving a lazyloaded item! Got: " ~ T.stringof ~ " Needed: " ~ DirNode.stringof
                );
        if (type == NodeType.File) 
            assert(
                is(T == FileNode), 
                "Error! You must use the correct type for resolving a lazyloaded item! Got: " ~ T.stringof ~ " Needed: " ~ FileNode.stringof
                );
        return cast(T) item;
    }

    static ResolvedLazyloadItem from(T)(T value, uint ptr){
        static assert(
           isCorrect!T
        );
        
        ResolvedLazyloadItem ret;
        ret.ptr = ptr;

        static if(is(T == DirNode))
            ret.type = NodeType.Directory;
        static if(is(T == FileNode))
            ret.type = NodeType.File;
        ret.item = cast(void*) value;
        return ret;

    }
}

struct UnResolvedLazyloadItem{
    NodeType nodeType;
    string name;
    uint ptr;
    DustyFs parent;

    ResolvedLazyloadItem resolve(){
        ResolvedLazyloadItem* found = ptr in parent.resolvableNodes;
        if (found) return *found;

        switch(nodeType){
            case NodeType.Directory:
                DirNode dir = new DirNode(ptr, parent);
                auto rlli = ResolvedLazyloadItem.from(dir, ptr);
                parent.resolvableNodes[ptr] = rlli;
                return rlli;
            case NodeType.File:
                FileNode dir = new FileNode(ptr, parent);
                auto rlli = ResolvedLazyloadItem.from(dir, ptr);
                parent.resolvableNodes[ptr] = rlli;
                return rlli;
            default:
                assert(0, "Invalid lazyloaded object!");
                break;
        }

    }

    T as(T)() => this.resolve().as!T;
}


