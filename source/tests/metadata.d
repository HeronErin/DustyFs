module tests.metadata;
import dustyfs.metadata;
import std.stdio;
// import tern.typecons;
import betterMemoryStream;


unittest{
    auto stream = new MemoryStream(new ubyte[0]);
    writeMetaMetadata(stream, MetaMetaData(NodeType.Directory, "Hello world!", 50000, 420000));
    writeMetaMetadata(stream, MetaMetaData(NodeType.Directory, "Hello world!", 50000, 420000));
    writeMetaMetadata(stream, MetaMetaData(NodeType.Directory, "Hello world!", 0, 9));

    stream.seek(0);

    assert(readMetaMetadata(stream) == MetaMetaData(NodeType.Directory, "Hello world!", 50000, 420000));
    assert(readMetaMetadata(stream) == MetaMetaData(NodeType.Directory, "Hello world!", 50000, 420000));
    assert(readMetaMetadata(stream) == MetaMetaData(NodeType.Directory, "Hello world!", 0, 9));
}
unittest{
    MetaData input;
    input.CreationDate = 69;

    auto stream = new MemoryStream(new ubyte[0]);
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
}
