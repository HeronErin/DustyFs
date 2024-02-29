module tests.abstractfs_test;
import dustyfs.fs : DustyFs;
import dustyfs.filenode;
import abstractfs;
import betterMemoryStream;
import std.stdio;

unittest{
    FileSystemInterface dfs = new DustyFs(new MemoryStream(new ubyte[0]), true);
    scope (exit) dfs.close();

    auto root = dfs.getRoot();
    root.touch("Hello").open().write(cast(ubyte[]) "world...");

    assert(
        root.listDir()[0].as!FileNode.open.read(8) == cast(ubyte[]) "world..."
        );


}
 
 
 
