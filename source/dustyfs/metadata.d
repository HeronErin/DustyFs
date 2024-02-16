module dustyfs.metadata;
import freck.streams.streaminterface;
import std.stdio;
//import std.typecons;
import caiman.typecons;

import utils;

// Meta data has two types.
//   1. Metadata, which is stored in the file itself
//   2. MetaMetadata, which is stored in all directory listings.

enum NodeType : ubyte{
    Directory,
    File,
    SymLink
}

// MetaData values are stored in the following format:
//  Amount of key/value pairs (ubyte):
//  List of Keys: (ubytes)
//  List of values Values: (VarInt ulong)

//  Rest of file...

enum MetaDataKeys : ubyte{
    CreationDate,
    AccessDate,
    PermisionBitmap,
    NodeHash,          // 0 = not yet taken. 1 = Never to be taken other. else: the last hash
    IsLocked           // 1 = never to be changed (validated with hash), 0 = not locked
}


struct MetaData{
    Nullable!ulong CreationDate;
    Nullable!ulong AccessDate;
    Nullable!ulong PermisionBitmap;
    Nullable!ulong NodeHash;
    Nullable!ulong IsLocked;

    uint LengthOfMetadata = 0;

    @property Nullable!ulong*[ubyte] lookupTable() =>[
        MetaDataKeys.CreationDate: &this.CreationDate,
        MetaDataKeys.AccessDate: &this.AccessDate,
        MetaDataKeys.PermisionBitmap: &this.PermisionBitmap,
        MetaDataKeys.NodeHash: &this.NodeHash,
        MetaDataKeys.IsLocked: &this.IsLocked
    ];
}



interface NodeWithMetadata{
    bool isDirty();
    void write();
}
MetaData readMetadata(StreamInterface si){
    si.seek(0);
    ubyte amount = si.readInt!ubyte();
    ubyte[] keys = si.read(amount);

    debug assert(keys.length == amount, "File read error");

    ulong[] values = si.fromVarIntStream!ulong(amount);

    debug assert(values.length == amount, "File read error");

    MetaData result;
    auto table = result.lookupTable;

    int i = 0;
    foreach (ubyte key ; keys){
        scope (exit) i++;

        Nullable!ulong** writeTo = key in table;
        assert(writeTo, "Key not found: " ~ key);

        **writeTo = values[i];
    }


    return result;

}

void writeMetadata(StreamInterface si, MetaData meta){
    import std.traits : EnumMembers;

    auto table = meta.lookupTable();
    auto keys = new ubyte[0];
    auto values = new ubyte[0];

    foreach (MetaDataKeys x ; [EnumMembers!MetaDataKeys]){
        if (table[x].isNull) continue;
        keys ~= cast(ubyte)x;
        values ~= table[x].value.toVarInt;
    }
    debug assert(keys.length <= ubyte.max);

    si.write(
        [cast(ubyte) keys.length]
        ~ keys
        ~ values
    );
}


struct MetaMetaData{
    NodeType nodeType;
    string name;
    uint size;
    uint ptr;

    bool isDirty = false;
    uint metaMetaDataOffset = 0;
}


bool isValidFileName(string name){
    if (name.length > 255) return false;
    if (name.length == 0) return false;
    return true;
}


void writeMetaMetadata(StreamInterface file, MetaMetaData mmd){
    assert(isValidFileName(mmd.name), "Invalid name");
    mmd.writeln();
    auto b = [cast(ubyte) mmd.nodeType, cast(ubyte) mmd.name.length] ~
        toVarInt(mmd.size) ~
        toVarInt(mmd.ptr)  ~ (cast(ubyte[]) mmd.name);
    b.writeln();
    file.write(b);
}
MetaMetaData readMetaMetadata(StreamInterface file){
    file.tell().writeln();
    ubyte[] nodeType_len = file.read(2);
    nodeType_len.writeln();

    assert(nodeType_len.length == 2, "Can't read first elements of MetaMetadata");


    ubyte intReadCount = 0;

    uint[] size_ptr = fromVarIntStream!uint(file, 2);

    ubyte[] name = file.read(nodeType_len[1]);

    assert(name.length == nodeType_len[1], "Can't read name in MetaMetadata");
    MetaMetaData ret;
    ret.nodeType = cast(NodeType)nodeType_len[0];
    ret.name = cast(string) name;
    ret.size = size_ptr[0];
    ret.ptr = size_ptr[1];
    return ret;


}





