module betterMemoryStream;
import freck.streams.streaminterface;


class MemoryStream : StreamInterface {
    protected Endian endian;
    protected ubyte[] buf;
    protected ssize_t ptr;
    protected string[string] metadata;

    bool isSeekable() => true;
    bool isWritable() => true;
    bool isReadable() => true;

    void setEndian(Endian e) {
        endian=e;
    }
    Endian getEndian() => endian;
    ssize_t tell() => ptr;
    ssize_t length() => buf.length;
    bool isEmpty() => buf.length == 0;

    ubyte[] getContents() => buf;
    string getMetadata(string key) => metadata == null ? null : metadata[key];

    this (ubyte[] buf, string[string] metadata = null, Endian e = Endian.platform){
        this.buf=buf;
        this.metadata=metadata;
        this.endian=e;
        this.ptr = 0;
    }

    protected void extentToFix(ssize_t extent){
        if (extent <= buf.length) return;
        buf ~= new ubyte[extent - buf.length];
        debug assert(extent <= buf.length);
    }

    ssize_t seek(in sdiff_t pos, in Seek origin = Seek.set){
        if (origin == Seek.set)
            this.ptr = pos;

        if (origin == Seek.cur)
            this.ptr += pos;

        if (origin == Seek.end)
            this.ptr = buf.length - origin;

        assert(this.ptr >= 0, "Invalid seek");

        return this.ptr;
    }

    void write(in ubyte b){
        extentToFix(this.ptr+1);
        buf[this.ptr] = b;
        this.ptr++;
    }
    void write(in ubyte[] b){
        extentToFix(ptr + b.length);
        buf[ptr..ptr + b.length] = b;
        this.ptr += b.length;
    }
    ubyte read(){
        return ptr > buf.length ? 0 : buf[ptr++];
    }
    ubyte[] read(in ulong n){
        ubyte[] ret = new ubyte[n];
        if (ptr > buf.length) return ret;

        import utils;
        auto readExtent = utils.min(ptr+n, buf.length);

        ubyte[] rslice = buf[ptr..readExtent];
        this.ptr=readExtent;

        ret[0..rslice.length] = rslice;

        return ret;

    }
}
 
 
