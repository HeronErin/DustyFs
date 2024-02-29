module tests.dustyfs_test;
import betterMemoryStream;
import dustyfs.fs : DustyFs;
import dustyfs.dirnode : DirNode;
import dustyfs.filenode;
import std.stdio;

unittest{
    DustyFs dfs;
    DirNode dir;
    DirNode d3;
    DirNode d4;
    DFile file;

    import std.algorithm;
    import std.array;


    uint u = 0;
    const ubyte[] testBytes = (new ubyte[1024*1024*2]).map!(_=>cast(ubyte)(u++ % 0xFF)).array;

    static foreach(openas; ["\"dustyfs.dust\"", "new MemoryStream(new ubyte[0])"]){
        dfs = new DustyFs(mixin(openas), true);
        

        
        dfs.root.mkDir("Test data");
        dir = dfs.root.listDir()[0].as!DirNode;

        d3 = dir.mkDir("More test data");
        d3.mkDir("1");
        d3.mkDir("2");

        d4 = dir.mkDir("Yet More test data");
        d4.mkDir("a1");
        d4.mkDir("a2").mkDir("b2").mkDir("b3");
        d4.mkDir("a3");
        dfs.root.mkDir("Some non-test data");

        import baseStreamTest;
        basicStreamTest(d4.touch("Test").open());
        file = dfs.root.touch("test data").open();
        file.write(testBytes);

        
        dfs.close();

        dfs = new DustyFs("dustyfs.dust", false);
        assert(testBytes == dfs.root.get("test data").get.as!FileNode.open().read(testBytes.length));


        dfs.root.tree();

        dfs.close();
    }
}