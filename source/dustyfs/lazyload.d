module dustyfs.lazyload;

import dustyfs.fs;
import dustyfs.metadata;
import dustyfs.dirnode : DirNode;
import dustyfs.node : SIZE_OF_INITIAL_NODE_HEADER;

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
        return cast(T) item;
    }

    static ResolvedLazyloadItem from(T)(T value, uint ptr){
        static assert(
            is(T == DirNode)
        );
        
        ResolvedLazyloadItem ret;
        ret.ptr = ptr;

        static if(is(T == DirNode))
            ret.type = NodeType.Directory;

        ret.item = cast(void*) value;
        return ret;

    }
}

struct UnResolvedLazyloadItem{
    string name;
    uint ptr;
    DustyFs parent;

    protected NodeType peekType(){
        parent.allocator.file.seek(SIZE_OF_INITIAL_NODE_HEADER);

        ubyte typeOfNode = parent.allocator.file.read();

        assert (typeOfNode <= NodeType.max, "Invalid dustyfs item!");
        return cast(NodeType) typeOfNode;
    }
    ResolvedLazyloadItem resolve(){
        ResolvedLazyloadItem* found = ptr in parent.resolvableNodes;
        if (found) return *found;

        switch(peekType()){
            case NodeType.Directory:
                DirNode dir = new DirNode(ptr, parent);
                auto rlli = ResolvedLazyloadItem.from(dir, ptr);
                parent.resolvableNodes[ptr] = rlli;
                return rlli;
            case NodeType.File:
                assert(0);
            default:
                assert(0);
                break;
        }

    }
}


