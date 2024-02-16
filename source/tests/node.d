module tests.node;
import dustyfs.node;
import freck.streams.memorystream;
import falloc;

unittest{
    auto data = new ubyte[0];
    auto nodeStream = new NodeStream(new falloc.FileAlloc(MemoryStream.fromBytes(data), true));
    nodeStream.write(cast(ubyte[])"sahdhassd");

    scope (exit) nodeStream.close();
}


