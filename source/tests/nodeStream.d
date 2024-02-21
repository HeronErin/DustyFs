module tests.nodeStream;
import dustyfs.node;
import falloc;

import betterMemoryStream;
import freck.streams.streaminterface;
import freck.streams.filestream;

import utils;

import std.stdio;

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

            enum testPhrase = cast(ubyte[])"Hello file World! This is some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!Hello file World! This is some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!Hello file World! This is some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!Hello file World! This is some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!Hello file World! This is some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!Hello file World! This is some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!Hello file World! This is some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!Hello file World! This is some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!Hello file World! This is some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!some test data!!!!";


            nodeStream.seek(0);
            nodeStream.write(testPhrase);
            nodeStream.seek(0);
            assert(testPhrase == nodeStream.read(testPhrase.length));

            nodeStream.seek(99999);
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


unittest{
    auto data = new ubyte[0];

    auto mem = new MemoryStream(data);
    auto alloc = new falloc.FileAlloc(mem, true);

    auto nodeStream = new NodeStream(alloc);

    enum testString = cast(ubyte[])"123455678 asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w123455678 asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w123455678 asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w123455678 asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w123455678 asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w123455678 asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w123455678 asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w123455678 asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w123455678 asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w123455678 asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w123455678 asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w asdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji wasdjasjdkjasdkj kajsdkj kasj dkjask jkdj  mkmasmdokasijdn iasndj nasdmoasn jodnasndko asjidnaji w";
    enum testString2 = cast(ubyte[])"_10_11_12";

    enum fullTestString = testString ~ testString2;

    nodeStream.write(testString);
    nodeStream.write(testString2);
    nodeStream.close();


    data = mem.getContents;
    alloc.close();

    mem = new MemoryStream(data);
    alloc = new falloc.FileAlloc(mem, false);

    nodeStream = new NodeStream(25, alloc);

    nodeStream.seek(0);
    auto x = nodeStream.read(fullTestString.length);

    assert(fullTestString == x);

    nodeStream.close();
    alloc.close();

}