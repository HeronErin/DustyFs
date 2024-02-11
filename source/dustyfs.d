module dustyfs;
import falloc;
import freck.streams.filestream;
import freck.streams.streaminterface;

import std.typecons;
import utils;
import std.stdio;
// "Files" / Nodes are broken up into multiple subNodes.

// The initial node is as following in the file:
// uint nextprt
// ushort size of sub node
// uint size of node (rounded)
// uint true size of node

// Sub nodes are as follows:
// uint nextprt
// ushort size of sub node


enum SIZE_OF_INITIAL_NODE_HEADER = uint.sizeof + ushort.sizeof + uint.sizeof + uint.sizeof + uint.sizeof;
enum SIZE_OF_SUB_NODE_HEADER = uint.sizeof + ushort.sizeof;

enum DEFAULT_NODE_CREATION_SIZE = 128;


struct SubNode{
    uint offset;

    uint nextPrt;
    ushort subNodeSize;

    void write(FileAlloc alloc){
        alloc.file.seek(offset);
        alloc.writeInt!uint(nextPrt);
        alloc.writeInt!ushort(subNodeSize);
    }
    static SubNode fromOffset(FileAlloc alloc, uint offset){
        alloc.file.seek(offset);
        return SubNode(
            offset,
            alloc.readInt!uint(),
            alloc.readInt!ushort()
        );
    }
}

class NodeStream : StreamInterface{
    DustyFs parent;
    protected FileAlloc allocator;

    uint initialOffset;
    uint knownEndNodeOffset;

    uint reservedSize;
    uint userlandSize;

    SubNode[] nodes;

    // Make new node
    this(DustyFs parent, uint suggestedSize=DEFAULT_NODE_CREATION_SIZE){
        suggestedSize+=SIZE_OF_INITIAL_NODE_HEADER;

        bool weMustSplitUp = ushort.max <= suggestedSize;
        ushort initialNodeSize =  weMustSplitUp ? ushort.max : cast(ushort)suggestedSize ;

        const int start = parent.allocator.alloc(suggestedSize);

        parent.allocator.file.seek(start);

        parent.allocator.writeInt!uint(0);                  // Next pointer
        parent.allocator.writeInt!ushort(initialNodeSize);  // Sub-node size
        parent.allocator.writeInt!uint(suggestedSize);      // On-disk, reserved, node size
        parent.allocator.writeInt!uint(0);                  // Userland file size

        this(parent, start, start);
        if (!weMustSplitUp) return;

        suggestedSize -= ushort.max;


        while (suggestedSize){


            ushort nodeSize = cast(ushort) utils.min(cast(uint)ushort.max, suggestedSize);
            auto offsetOfSubNode = allocator.alloc(nodeSize+SIZE_OF_SUB_NODE_HEADER);

            assert(offsetOfSubNode != 0);

            SubNode node = SubNode(offsetOfSubNode, 0, nodeSize);
            nodes[$-1].nextPrt = node.offset;
            this.nodes ~= node;

            assert(suggestedSize>=nodeSize);
            suggestedSize-= nodeSize;

        }
        foreach(ref SubNode node ; nodes)
            node.write(allocator);

        userlandPos=0;


    }

    // From existing node
    this(DustyFs parent, uint offset, uint endingOffset){
        this.parent = parent;
        this.initialOffset = offset;
        this.knownEndNodeOffset = offset;
        this.allocator = parent.allocator;

        this.nodes ~= SubNode.fromOffset(parent.allocator, offset);
        this.reservedSize = parent.allocator.readInt!uint();
        this.userlandSize = parent.allocator.readInt!uint();
        userlandPos=0;
    }


    import std.string : StringException;

    void setEndian(Endian _) => throw new StringException("Not a supported operation.");
    Endian getEndian() => parent.allocator.file.getEndian();
    ssize_t length() => userlandSize;
    bool isEmpty() => parent.allocator.file.isEmpty();
    bool isSeekable() => parent.allocator.file.isSeekable();
    bool isWritable() => parent.allocator.file.isWritable();
    bool isReadable() => parent.allocator.file.isReadable();

    uint userlandPos = 0;

    ssize_t tell() => userlandPos;

    ulong seek(in long pos, in Seek origin = Seek.set) {
        switch (origin){
            case Seek.set:
                assert(pos >= 0, "Invalid seek");
                userlandPos = cast(uint) pos;
                return userlandPos;
            case Seek.cur:
                long npos = userlandPos + pos;
                assert(npos >= 0, "Invalid seek");
                userlandPos=cast(uint) npos;
                return userlandPos;
            case Seek.end:
                long npos = userlandSize+pos;
                assert(npos >= 0, "Invalid seek");
                userlandPos=cast(uint) npos;
                return userlandPos;
            default: assert(0, "Wtf??");
        }
        assert(0, "Not reachable");
    }


    Tuple!(uint, uint)[] makeLengthWiseOffsets(uint length, uint searchPos=uint.max){
        assert(length > 0);

        if (searchPos == uint.max) searchPos = this.userlandPos;

                                        // Offset, length
        auto offsetsToReturn = new Tuple!(uint, uint)[0];

        long offsetWithinNode = 0;

        bool firstIteration = true;
        foreach (ref SubNode node ; nodes){
            scope (exit) firstIteration = false;

            // Nodes are prepended with headers, we must skip that
            const auto headerSize = firstIteration ? SIZE_OF_INITIAL_NODE_HEADER : SIZE_OF_SUB_NODE_HEADER;

            const long scopeEnd = offsetWithinNode + node.subNodeSize - headerSize;

            scope (exit) offsetWithinNode=scopeEnd;


            // We are looking for a node that contains part of the memory we are looking for
            if (scopeEnd < searchPos) continue;

            assert(searchPos >= offsetWithinNode);
            const long offsetWithinSubNode = searchPos-offsetWithinNode;

            assert(offsetWithinSubNode >= 0);

            const long fileOffset = node.offset + headerSize + (searchPos - offsetWithinNode);

            const long amountToReadInNode = utils.min(node.subNodeSize - offsetWithinSubNode - headerSize, length);
            assert(amountToReadInNode >= 0);

            length-=amountToReadInNode;
            searchPos+=amountToReadInNode;

            offsetsToReturn ~= tuple(cast(uint) fileOffset, cast(uint) amountToReadInNode);


            if (length == 0) break;

        }
        return offsetsToReturn;
    }

    void write(in ubyte b) => this.write([b]);
    void write(in ubyte[] b){
        long writeExtent = userlandPos + b.length;

        while (writeExtent > reservedSize-SIZE_OF_INITIAL_NODE_HEADER){
            ushort nodeSize = cast(ushort) utils.min(cast(uint)ushort.max - SIZE_OF_SUB_NODE_HEADER, writeExtent - (reservedSize - SIZE_OF_INITIAL_NODE_HEADER));

            auto offsetOfSubNode = allocator.alloc(nodeSize+SIZE_OF_SUB_NODE_HEADER);

            assert(offsetOfSubNode != 0);

            SubNode nodeToAdd = SubNode(offsetOfSubNode, 0, cast(ushort)( nodeSize+SIZE_OF_SUB_NODE_HEADER ));
            nodes[$-1].nextPrt = nodeToAdd.offset;
            this.nodes ~= nodeToAdd;

            assert(writeExtent>=nodeSize);
            writeExtent-= nodeSize;
            this.reservedSize+=nodeSize;
        }

        writeExtent = userlandPos + b.length;

        // This is safe as we _should_ have extended the node to be large enough
        if (userlandSize < writeExtent)
            userlandSize = cast(uint) writeExtent;

        uint writeArrayOffset = 0;
        foreach (ref Tuple!(uint, uint) offset_length ; this.makeLengthWiseOffsets(cast(uint) b.length)){
            offset_length.writeln();
            allocator.file.seek(offset_length[0]);
            allocator.file.write(
                b[
                    writeArrayOffset .. writeArrayOffset += offset_length[1]
                ]);
        }
        userlandPos+=writeArrayOffset;

    }

    ubyte read() => this.read(1)[0];
    ubyte[] read(in ulong n){
        ubyte[] ret = new ubyte[n];

        uint readArrayOffset = 0;
        foreach (ref Tuple!(uint, uint) offset_length ; this.makeLengthWiseOffsets(cast(uint) n)){
            offset_length.writeln();
            allocator.file.seek(offset_length[0]);
            const ubyte[] fromFile = allocator.file.read(offset_length[1]);
            ret[readArrayOffset .. readArrayOffset+fromFile.length] = fromFile;
            readArrayOffset+=offset_length[1];
        }
        userlandPos += readArrayOffset;
        return ret;
    }
    ubyte[] getContents(){
        this.seek(0);
        return this.read(userlandSize);
    }

    string getMetadata(string key) => parent.allocator.file.getMetadata(key);
}



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

