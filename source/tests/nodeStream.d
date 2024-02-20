module tests.nodeStream;
import dustyfs.node;
import falloc;

import betterMemoryStream;
import freck.streams.streaminterface;
import freck.streams.filestream;

import utils;

// A lot of nested loops, but confirms nodeStream is working...

unittest{
    foreach(StreamInterface sourceStream ; [
        cast(StreamInterface) new FileStream("nodestream.dust", "w+b"),
        cast(StreamInterface) new MemoryStream(new ubyte[0])
    ]){
        auto alloc = new falloc.FileAlloc(sourceStream, true);

        auto backlog = new NodeStream[0];
        foreach (i; 0..100){
            auto nodeStream = new NodeStream(alloc);
            scope (exit) backlog~=nodeStream;

            import baseStreamTest;
            basicStreamTest(nodeStream);

            enum testPhrase = cast(ubyte[])"Hello file World! This is some test data!!!!";


            nodeStream.seek(0);
            nodeStream.write(testPhrase);
            nodeStream.seek(0);
            assert(testPhrase == nodeStream.read(testPhrase.length));

            nodeStream.seek(999);
            assert(nodeStream.read(512) == new ubyte[512]);

            nodeStream.seek(0);

            nodeStream.writeInt!uint(i);

            nodeStream.seek(0);
            assert(nodeStream.readInt!uint() == i);

            foreach (ii; 1..100){
                if (i > ii){
                    backlog[$-ii].seek(0);
                    assert(backlog[$-ii].readInt!uint() == i-ii);
                }
            }

        }
        foreach (b; backlog) b.close();
        alloc.close();

    }

    import std.stdio;
    "Passed NodeStream test".writeln();
}


