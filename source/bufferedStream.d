module bufferedStream;
import freck.streams.streaminterface;
import std.typecons : tuple, Tuple;
import std.stdio;
public import freck.streams.streaminterface : Seek;


import utils;

enum MAX_BUFF_CAPACITY = 10*1024*1024;


class BufferedStream{
    ulong userlandPos;
    ssize_t userlandSize;
    ulong truePos;


    ulong startBuffPos;
    ubyte[] bufferChuncks = new ubyte[0];


    StreamInterface stream;
    this(StreamInterface stream){
        this.stream = stream;
        truePos=stream.tell();
        userlandPos=truePos;
        userlandSize=stream.length();

        bufferChuncks.reserve(MAX_BUFF_CAPACITY);
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

        if (userlandPos >= startBuffPos && userlandPos <= startBuffPos+bufferChuncks.length)
            return userlandPos;
        this.flush();
        startBuffPos = userlandPos;
        return userlandPos;

    }

    void write(in ubyte b){
        bufferChuncks~=b;
    }
    void write(in ubyte[] b){
        bufferChuncks~=b;
    }
    ubyte read() => stream.read();
    ubyte[] read(in ulong n) => stream.read(n);

    void flush(){
        if (0 == bufferChuncks.length) return;
        if (truePos != startBuffPos) {
            stream.seek(startBuffPos);
            truePos=startBuffPos;
        }
        writeln("Writing ", bufferChuncks.length, " elements at ", startBuffPos);

        stream.write(bufferChuncks);

        startBuffPos = truePos = stream.tell();
        bufferChuncks.length = 0;

    }
}

 
