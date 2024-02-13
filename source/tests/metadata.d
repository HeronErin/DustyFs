module tests.metadata;
import dustyfs.metadata;
import std.stdio;

unittest{
    import freck.streams.memorystream;

    auto stream = MemoryStream.fromBytes([]);
    writeMetaMetadata(stream, MetaMetaData(NodeType.Directory, "Hello world!", 50000, 420000));
    stream.seek(0);

    assert(readMetaMetadata(stream) == MetaMetaData(NodeType.Directory, "Hello world!", 50000, 420000));

    "Passed MetaMetadata stream test".writeln();
}
//unittest{
//    import freck.streams.memorystream;
//}
