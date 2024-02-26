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

    @safe protected void extentToFix(ssize_t extent){
        if (extent < this.buf.length) return;
        this.buf.reserve(extent+1);
        this.buf.length = extent;
        debug assert(extent <= this.buf.length);
    }

    @safe @nogc ssize_t seek(in sdiff_t pos, in Seek origin = Seek.set){
        if (origin == Seek.set)
            this.ptr = pos;

        if (origin == Seek.cur)
            this.ptr += pos;

        if (origin == Seek.end)
            this.ptr = buf.length + pos;

        assert(this.ptr >= 0, "Invalid seek");

        return this.ptr;
    }

    @safe void write(in ubyte b){
        extentToFix(this.ptr+1);
        buf[this.ptr++] = b;
    }
    @safe void write(in ubyte[] b){
        extentToFix(ptr + b.length);
        buf[ptr..ptr + b.length] = b;
        this.ptr += b.length;
    }
    @safe ubyte read(){
        return ptr > buf.length ? 0 : buf[ptr++];
    }
    @safe ubyte[] read(in ulong n){
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
 
 
