module tests.metadata;
import dustyfs.metadata;
import std.stdio;
import caiman.typecons;
unittest{
    import freck.streams.memorystream;

    auto stream = MemoryStream.fromBytes([]);
    writeMetaMetadata(stream, MetaMetaData(NodeType.Directory, "Hello world!", 50000, 420000));
    stream.seek(0);

    assert(readMetaMetadata(stream) == MetaMetaData(NodeType.Directory, "Hello world!", 50000, 420000));

    "Passed MetaMetadata stream test".writeln();
}
unittest{
    import freck.streams.memorystream;
    MetaData input;
    input.CreationDate = 69;

    auto stream = MemoryStream.fromBytes(new ubyte[0]);;
    stream.writeMetadata(input);
    stream.seek(0);

    assert(stream.readMetadata() == input);

    input.CreationDate = uint.max;
    input.AccessDate = ushort.max;
    input.PermisionBitmap = 0xFEEDBEEF;

    stream.seek(0);
    stream.writeMetadata(input);
    stream.seek(0);
    assert(stream.readMetadata() == input);


    "Passed Metadata test".writeln();
}
