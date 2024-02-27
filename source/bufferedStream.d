module bufferedStream;
import freck.streams.streaminterface;
import std.typecons : tuple, Tuple;
import std.stdio;
public import freck.streams.streaminterface : Seek;

struct BChunk{
    ulong start;
    ulong end;
    ubyte[] buff = new ubyte[0];
}
import utils;

enum MAX_BUFF_CAPACITY = 10*1024*1024;


// We want to group writes together to speed up file IO. (Although the os likely does this for us)
class BufferedStream{
    ssize_t userlandPos;
    ssize_t userlandSize;
    BChunk[] bufferChuncks = new BChunk[0];
    BChunk* curr_write = null;

    StreamInterface stream;
    this(StreamInterface stream){
        this.stream = stream;
        userlandPos = stream.tell();
        userlandSize = stream.length();

        bufferChuncks~=BChunk(0, ulong.max);
        curr_write = &bufferChuncks[$-1];
    }




    // Most things are just proxied
    void setEndian(Endian e) => stream.setEndian(e);
    Endian getEndian() => stream.getEndian();
    ssize_t length() => userlandSize;


    bool isEmpty() => stream.isEmpty();
    bool isSeekable() => stream.isSeekable();
    bool isWritable() => stream.isWritable();
    bool isReadable() => stream.isReadable();

    ulong tell() => stream.tell();
    string getMetadata(string key) => stream.getMetadata(key);
    protected BChunk* getChunckForPos(long pos){
        foreach(ref node ; bufferChuncks){
            if (node.start <= pos && node.end > pos)
                return &node;
        }
        return null;
    }
    protected BChunk* getChunckForPos(long pos, BChunk* not){
        foreach(ref node ; bufferChuncks){
            if (not is &node) continue;
            if (node.start <= pos && node.end > pos)
                return &node;
        }
        return null;
    }
    protected void makeLengthWiseOffsets(long size, void delegate(BChunk*, ulong, ulong) callback){
        BChunk* curr = curr_write;
        do{
            START_OF_LOOP:
            auto extent = utils.min(size, curr.end - curr.start);
            if (extent != 0)
                callback(curr, userlandPos - curr.start, extent);

            userlandPos+=extent;
            size-=extent;

            if (size == 0) return;

            curr = getChunckForPos(userlandPos, curr);
            userlandPos.writeln();
            curr.writeln();
            if (curr) continue;
            assert(0);

            ulong max = ulong.max;
            foreach(ref node ; bufferChuncks){
                if (node.start < userlandPos) continue;
                max = utils.min(max, node.start);
            }
            "Making new node".writeln();

            bufferChuncks~=BChunk(userlandPos, max);
            curr = curr_write = &bufferChuncks[$-1];



        }while(true);

    }


    ubyte[] getContents() =>stream.getContents();
    ulong seek(in long pos, in Seek origin = Seek.set){
        switch (origin){
            case Seek.set:
                assert(pos >= 0, "Invalid seek");
                userlandPos = cast(uint) pos;
                break;
            case Seek.cur:
                long npos = userlandPos + pos;
                assert(npos >= 0, "Invalid seek");
                userlandPos=cast(uint) npos;
                break;
            case Seek.end:
                long npos = userlandSize+pos;
                assert(npos >= 0, "Invalid seek");
                userlandPos=cast(uint) npos;
                break;
            default: assert(0, "Wtf??");
        }
        assert(userlandPos>=0);

        if (curr_write.start <= userlandPos && curr_write.start+curr_write.buff.length >= userlandPos)
            return userlandPos;

        BChunk* inSideOf = getChunckForPos(userlandPos);
        if (inSideOf is null){
            if (curr_write.end > userlandPos) curr_write.end = userlandPos;

            bufferChuncks~= BChunk(userlandPos, ulong.max);
            inSideOf = &bufferChuncks[$-1];
            foreach(ref node ; bufferChuncks){
                if (&node is inSideOf) continue;
                if (node.start >= userlandPos && node.end >= userlandPos)
                    inSideOf.end = utils.min(inSideOf.end, node.start);
            }


        }
        curr_write = inSideOf;
        return userlandPos;


    }

    void write(in ubyte b){

    }
    void write(in ubyte[] b){
        if (b.length > MAX_BUFF_CAPACITY){
            this.flush();
            stream.seek(userlandPos);
            stream.write(b);
        }

        ssize_t pos = 0;
        makeLengthWiseOffsets(b.length, (chunck, offset, length){
            writeln("Write to: ", *chunck," ", offset," ", length );
            ssize_t newLength =  utils.max(offset+length, chunck.buff.length);
            chunck.buff.reserve(newLength);
            chunck.buff.length = newLength;
            chunck.buff[offset..offset+length] = b[pos..pos+=length];
        });
        userlandSize = utils.max(userlandPos, userlandSize);
    }
    ubyte read() => stream.read();
    ubyte[] read(in ulong n) => stream.read(n);

    void flush(){
        foreach(ref node ; bufferChuncks){
            stream.seek(node.start);
            stream.write(node.buff);

        }
        bufferChuncks.length = 0;
    }
}

 
