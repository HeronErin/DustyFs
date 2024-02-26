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

void main(){
    auto stream = new NodeStream(new falloc.FileAlloc(new MemoryStream(new ubyte[0]), true));
    long u = 0;
    const ubyte[] test_byte_data = (new ubyte[1024*1024*5]).map!(_=>cast(ubyte)(u++ % 0xFF)).array;
    stream.write(test_byte_data);
    stream.seek(0);
    auto d = stream.read(test_byte_data.length);
    assert(d == test_byte_data);
    //foreach (ubyte b ; test_byte_data)
    //    stream.write(b);


    //DustyFs dfs = new DustyFs("dustyfs.dust", true);
    //
    //FileNode file = dfs.root.touch("test.dust");
    //auto f = file.open();
    //
    //DustyFs df2 = new DustyFs(f, true);
    //
    //df2.root.touch("Nested").open().write(cast(ubyte[]) "This is a nested text file");
    //df2.close();
    //dfs.close();
    //
    //dfs = new DustyFs("dustyfs.dust", false);
    //scope (exit) dfs.close();
    //
    //
    //df2 = new DustyFs(dfs.root.get("test.dust").get.as!FileNode.open(), false);
    //scope(exit) df2.close();
    //
    //(cast(string)df2.root.get("Nested").get().as!FileNode.open().getContents()).writeln();

    stream.close();
    stream.allocator.close();


    // dfs.allocator.printAllocTree();

}
