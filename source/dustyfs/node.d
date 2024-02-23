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
module dustyfs.node;
 
 
 

import falloc;
import freck.streams.filestream;
import freck.streams.streaminterface;

import std.typecons;
import utils;
import std.stdio;
import std.logger;



import dustyfs.fs;






enum SIZE_OF_INITIAL_NODE_HEADER = uint.sizeof + ushort.sizeof + uint.sizeof + uint.sizeof + uint.sizeof;
enum SIZE_OF_SUB_NODE_HEADER = uint.sizeof + ushort.sizeof;

enum DEFAULT_NODE_CREATION_SIZE = 128;

struct SubNode{
    uint offset;

    uint nextPrt;
    ushort subNodeSize;

    void write(FileAlloc alloc){
        alloc.file.seek(offset);
        alloc.file.writeInt!uint(nextPrt);
        alloc.file.writeInt!ushort(subNodeSize);
    }
    static SubNode fromOffset(FileAlloc alloc, uint offset){
        alloc.file.seek(offset);
        return SubNode(
            offset,
            alloc.file.readInt!uint(),
            alloc.file.readInt!ushort()
        );
    }
}

class NodeStream : StreamInterface{
    //DustyFs parent;
    FileAlloc allocator;
    protected bool isClosed = false;
    protected bool isDirty = false;

    uint initialOffset;
    uint knownEndNodeOffset;

    uint reservedSize;
    uint userlandSize;

    SubNode[] nodes;

    // Make new node
    this(FileAlloc parent, uint reserveSize=DEFAULT_NODE_CREATION_SIZE){

        reserveSize+=SIZE_OF_INITIAL_NODE_HEADER;

        bool weMustSplitUp = ushort.max <= reserveSize;
        ushort initialNodeSize =  weMustSplitUp ? ushort.max : cast(ushort)reserveSize ;
        allocator=parent;


        const int start = allocator.alloc(reserveSize);

        allocator.file.seek(start);

        allocator.file.writeInt!uint(0);                  // Next pointer
        allocator.file.writeInt!ushort(initialNodeSize);  // Sub-node size
        allocator.file.writeInt!uint(reserveSize);      // On-disk, reserved, node size
        allocator.file.writeInt!uint(0);                  // Userland file size

        this(start, parent);
        if (!weMustSplitUp) return;

        reserveSize -= ushort.max;


        while (reserveSize){


            ushort nodeSize = cast(ushort) utils.min(cast(uint)ushort.max, reserveSize);
            auto offsetOfSubNode = allocator.alloc(nodeSize+SIZE_OF_SUB_NODE_HEADER);

            assert(offsetOfSubNode != 0);

            SubNode node = SubNode(offsetOfSubNode, 0, nodeSize);
            nodes[$-1].nextPrt = node.offset;
            this.nodes ~= node;

            assert(reserveSize>=nodeSize);
            reserveSize-= nodeSize;

        }
        foreach(ref SubNode node ; nodes)
            node.write(allocator);

        userlandPos=0;

        isDirty=true;


    }

    // From existing node
    this(uint offset, FileAlloc parent){
        //this.parent = parent;
        this.initialOffset = offset;
        this.knownEndNodeOffset = offset;
        this.allocator = parent;

        
        SubNode itr;
        do{
            itr = SubNode.fromOffset(allocator, offset);
            nodes ~= itr;
            offset = itr.nextPrt;
        }while (offset);
        

        this.reservedSize = allocator.file.readInt!uint();
        this.userlandSize = allocator.file.readInt!uint();
        userlandPos=0;
    }


    import std.string : StringException;

    void setEndian(Endian _) => throw new StringException("Not a supported operation.");
    Endian getEndian() => allocator.file.getEndian();
    ssize_t length() => userlandSize;
    bool isEmpty() => allocator.file.isEmpty();
    bool isSeekable() => allocator.file.isSeekable();
    bool isWritable() => allocator.file.isWritable();
    bool isReadable() => allocator.file.isReadable();

    uint userlandPos = 0;

    ssize_t tell() => userlandPos;

    ulong seek(in long pos, in Seek origin = Seek.set) {
        this.flush();
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
        assert(0);
    }

    Tuple!(uint, uint)[] makeLengthWiseOffsets(uint length, uint searchPos=uint.max){
        assert(length >= 0);

        if (searchPos == uint.max) searchPos = this.userlandPos;

                                        // Offset, length
        auto offsetsToReturn = new Tuple!(uint, uint)[0];

        long offsetWithinNode = 0;

        bool firstIteration = true;
        // writeln("Making offset at ", searchPos, " rs: ", reservedSize, " uland ", userlandSize, " OF: ", length);
        // nodes.writeln();

        foreach (ref SubNode node ; nodes){
            scope (exit) firstIteration = false;

            // Nodes are prepended with headers, we must skip that
            const auto headerSize = firstIteration ? SIZE_OF_INITIAL_NODE_HEADER : SIZE_OF_SUB_NODE_HEADER;

            const long scopeEnd = offsetWithinNode + node.subNodeSize - headerSize;

            scope (exit) offsetWithinNode=scopeEnd;

            // writeln("Working a subnode of size ", node.subNodeSize, " and a true size of ", node.subNodeSize-headerSize);


            // We are looking for a node that contains part of the memory we are looking for
            if (scopeEnd < searchPos) continue;

            debug assert(searchPos >= offsetWithinNode);
            const long offsetWithinSubNode = searchPos-offsetWithinNode;

            debug assert(offsetWithinSubNode >= 0);

            const long fileOffset = node.offset + headerSize + (searchPos - offsetWithinNode);

            const long amountToReadInNode = utils.min(node.subNodeSize - offsetWithinSubNode - headerSize, length);
            debug assert(amountToReadInNode >= 0);

            length-=amountToReadInNode;
            searchPos+=amountToReadInNode;

            offsetsToReturn ~= tuple(cast(uint) fileOffset, cast(uint) amountToReadInNode);


            if (length == 0) break;
        }
        // writeln("Lengthwise offsets", offsetsToReturn);
        return offsetsToReturn;
    }
    
    @safe @nogc protected uint getRecommendedGrowthSize(){
        if (reservedSize <= 512)
            return 128;
        if (reservedSize <= 2048)
            return 1024;
        if (reservedSize <= 16384)
            return 8192;
        if(reservedSize <= 32768)
            return 16384;
        
        return ushort.max-SIZE_OF_SUB_NODE_HEADER;
        
    }


    protected uint nextCorrectWritePos = uint.max;
    protected uint smallWriteBufferStart = uint.max;
    protected ubyte[] smallWriteBuffer = new ubyte[0];

    // void write(in ubyte b) => this.write([b]);
    void flush(){
        scope(exit) nextCorrectWritePos = uint.max;
        scope(exit) smallWriteBufferStart = uint.max;
        scope(exit) smallWriteBuffer = [];

        if (smallWriteBuffer.length == 0) return;
        if (smallWriteBufferStart == uint.max) return;
        //"Flushing small edit buffer".writeln();

        auto oldPos = this.userlandPos;

        this.userlandPos = smallWriteBufferStart;
        this.write(smallWriteBuffer, true);
        this.userlandPos = oldPos;

    }

    // This may be called a LOT, so it must be FAST
    void write(in ubyte b){
        //this.write([b]);
        if (nextCorrectWritePos != userlandPos || false) //smallWriteBuffer.length > 1024*1024*10)
            this.flush();
        //
        //// We get to reinit!
        if (nextCorrectWritePos == uint.max || smallWriteBufferStart == uint.max)
            smallWriteBufferStart = userlandPos;

        smallWriteBuffer ~= b;
        nextCorrectWritePos = ++userlandPos;
    }
    void write(in ubyte[] b) => write(b, false);
    void write(in ubyte[] b, bool isDirect){
        //if (b.length == 1) return write(b[0]);
        //if (false == isDirect || b.length < 100){
        //    if (nextCorrectWritePos != userlandPos)
        //        this.flush();
        //    if (nextCorrectWritePos == uint.max || smallWriteBufferStart == uint.max)
        //        smallWriteBufferStart = userlandPos;
        //    smallWriteBuffer ~= b;
        //    nextCorrectWritePos = userlandPos+cast(uint) b.length;
        //    return;
        //}


        long writeExtent = userlandPos + b.length;

        while (writeExtent > reservedSize-SIZE_OF_INITIAL_NODE_HEADER){
            isDirty=true;
            ushort nodeSize = cast(ushort) utils.min(cast(uint)ushort.max - SIZE_OF_SUB_NODE_HEADER, 
                utils.max(
                    getRecommendedGrowthSize(),
                    writeExtent - this.reservedSize
                )
            );

            auto offsetOfSubNode = allocator.alloc(nodeSize+SIZE_OF_SUB_NODE_HEADER);

            assert(offsetOfSubNode != 0);

            SubNode nodeToAdd = SubNode(offsetOfSubNode, 0, cast(ushort)( nodeSize+SIZE_OF_SUB_NODE_HEADER ));
            nodes[$-1].nextPrt = nodeToAdd.offset;
            nodes[$-1].write(allocator);
            nodeToAdd.write(allocator);
            this.nodes ~= nodeToAdd;

            
            this.reservedSize+=nodeSize;
        }
        
        writeExtent = userlandPos + b.length;
        assert(writeExtent <= reservedSize-SIZE_OF_INITIAL_NODE_HEADER);

        // This is safe as we _should_ have extended the node to be large enough
        if (userlandSize < writeExtent){
            userlandSize = cast(uint) writeExtent;
            isDirty=true;
        }

        uint writeArrayOffset = 0;
        foreach (ref Tuple!(uint, uint) offset_length ; this.makeLengthWiseOffsets(cast(uint) b.length)){
            allocator.file.seek(offset_length[0]);
            allocator.file.write(
                b[
                    writeArrayOffset .. writeArrayOffset += offset_length[1]
                ]);
        }
        
        assert(writeArrayOffset == b.length);
        userlandPos+=writeArrayOffset;

    }

    ubyte read(){
        Tuple!(uint, uint)[] offsetA = this.makeLengthWiseOffsets(1);
        debug assert(offsetA.length == 1);
        allocator.file.seek(offsetA[0][0]);
        userlandPos++;
        return allocator.file.read();
    }

    ubyte[] read(in ulong n){
        ubyte[] ret = new ubyte[n];
        //if (n == 0) return ret;

        uint readArrayOffset = 0;
        foreach (ref Tuple!(uint, uint) offset_length ; this.makeLengthWiseOffsets(cast(uint) n)){
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

    string getMetadata(string key) => allocator.file.getMetadata(key);


    void close(){
        if (isClosed) return;
        this.isClosed = true;
        this.flush();
        if (!isDirty) return;

        nodes[0].write(allocator);
        allocator.file.writeInt!uint(this.reservedSize);
        allocator.file.writeInt!uint(this.userlandSize);
    }
    ~this(){
        if (!isClosed && !allocator.isClosed)
            this.close();
        else if (!isClosed)
            assert(0, "NodeStream was not closed. A NodeStream must never outlive the DustyFs it is a child of. Please manuelly call the .close() method!");
    }


}

