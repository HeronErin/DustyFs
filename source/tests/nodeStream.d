module tests.nodeStream;
import dustyfs.node;
import falloc;
import betterMemoryStream;



unittest{
    auto data = new ubyte[0];
    auto alloc = new falloc.FileAlloc(new MemoryStream(data), true);
    auto nodeStream = new NodeStream(alloc);


    import baseStreamTest;
    basicStreamTest(nodeStream);

    enum testPhrase = cast(ubyte[])"Hello file World! This is some test data!!!!";


    nodeStream.seek(0);
    nodeStream.write(testPhrase);
    nodeStream.seek(0);
    assert(testPhrase == nodeStream.read(testPhrase.length));

    nodeStream.seek(999);
    assert(nodeStream.read(512) == new ubyte[512]);

    nodeStream.close();
    alloc.close();
}


