module bufferedStream;
import freck.streams.streaminterface;
import std.typecons : tuple, Tuple;

struct BChunk{
    ssize_t start;
    ssize_t end;
    ubyte[] buff = new ubyte[0];
}

// We want to group writes together to speed up file IO. (Although the os likely does this for us)
class BufferedStream{
    BChunk[] bufferChuncks = new BChunk[0];

    StreamInterface stream;
    this(StreamInterface stream){
        this.stream = stream;
    }

    BChunk* curr_write = null;



    // Most things are just proxied

    void setEndian(Endian e) => stream.setEndian(e);
    Endian getEndian() => stream.getEndian();
    ssize_t length() => stream.length();


    bool isEmpty() => stream.isEmpty();
    bool isSeekable() => stream.isSeekable();
    bool isWritable() => stream.isWritable();
    bool isReadable() => stream.isReadable();

    ulong tell() => stream.tell();
    string getMetadata(string key) => stream.getMetadata(key);



    ubyte[] getContents() =>stream.getContents();
    ulong seek(in long pos, in Seek origin = Seek.set) => stream.seek(pos, origin);

    void write(in ubyte b)=> stream.write(b);
    void write(in ubyte[] b)=> stream.write(b);
    ubyte read() => stream.read();
    ubyte[] read(in ulong n) => stream.read(n);
}

 
