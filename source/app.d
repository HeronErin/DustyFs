import std.stdio;
import falloc;
import dustyfs.node;
import betterMemoryStream;
import freck.streams.filestream;
import utils;
import dustyfs : DustyFs;

import std.algorithm;
import std.array;

import dustyfs.lazyload;
import dustyfs.dirnode : DirNode;
import dustyfs.filenode : FileNode;

import bufferedStream;

void main(){
    auto stream = new MemoryStream(new ubyte[0]);
    auto s2 = new BufferedStream(stream);
    s2.write([1]);

    s2.seek(10);
    s2.write([9]);

    s2.seek(0);
    s2.bufferChuncks.writeln;
    s2.write(cast(ubyte[]) "Some test text that is bound to be quite long for this test");
    s2.flush();
    stream.seek(0);
    stream.getContents.writeln;

}
