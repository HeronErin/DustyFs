module dustyfs.metadata;
import freck.streams.streaminterface;
import std.stdio;
import std.typecons;

// Meta data has two types.
//   1. Metadata, which is stored in the file itself
//   2. MetaMetadata, which is stored in all directory listings.

enum NodeType : ubyte{
    Directory,
    File,
    SymLink
}

bool isValidFileName(string name){
    if (name.length > 255) return false;
    if (name.length == 0) return false;
    return true;
}

import utils;
void writeMetaMetadata(StreamInterface file, NodeType nodeType, string name, uint size, uint ptr){
    import std.array;

    assert(isValidFileName(name), "Invalid name");
    file.write(
            [cast(ubyte) nodeType, cast(ubyte) name.length] ~
            toVarInt(size) ~
            toVarInt(ptr)

    );
    file.write(cast(ubyte[]) name);
}
Tuple!(NodeType, string, uint, uint) readMetaMetadata(StreamInterface file){
    ubyte[] nodeType_len = file.read(2);

    assert(nodeType_len.length == 2, "Can't read first elements of MetaMetadata");



    ubyte intReadCount = 0;

    uint[] size_ptr = fromVarIntStream!uint(file, 2);

    ubyte[] name = file.read(nodeType_len[1]);

    assert(name.length == nodeType_len[1], "Can't read name in MetaMetadata");
    return tuple(cast(NodeType)nodeType_len[0], cast(string)name, size_ptr[0], size_ptr[1]);

}
unittest{
    //import freck.streams.memorystream;

    //auto stream = MemoryStream.fromBytes([]);
    //writeMetaMetadata(stream, NodeType.Directory, "Hello world!", 50000, 420000);
    //stream.seek(0);
    //readMetaMetadata(stream).writeln();
    //assert(readMetaMetadata(stream) == Tuple!(NodeType, string, uint, uint)(NodeType.Directory, "Hello world!", 69, 420));

}