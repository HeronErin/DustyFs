module utils;

public enum Endianness
{
    Native,
    LittleEndian,
    BigEndian
}
import std.algorithm.mutation;


// Credit: https://github.com/cetio/caiman/blob/main/source/caiman/conv.d

pragma(inline)
@trusted T toEndian(T)(T val, Endianness endianness)
{
    version (LittleEndian)
    {
        if (endianness == Endianness.BigEndian)
        {
            ubyte[] bytes = (cast(ubyte*)&val)[0..T.sizeof];

            bytes = bytes.reverse();

            val = *cast(T*)&bytes[0];
        }
    }
    else version (BigEndian)
    {
        if (endianness == Endianness.LittleEndian)
        {
            ubyte[] bytes = (cast(ubyte*)&val)[0..T.sizeof];
            bytes = bytes.reverse();
            val = *cast(T*)&bytes[0];
        }
    }

    return val;
}
pragma(inline)
@trusted T fromEndian(T)(T val, Endianness endianness){
    return toEndian(val, endianness);
}


pragma(inline)
@trusted @nogc T max(T)(T a, T b){
    return a > b ? a : b;
}
pragma(inline)
@trusted @nogc T min(T)(T a, T b){
    return a < b ? a : b;
}
import std.traits;
import std.stdio;


ubyte[] toVarInt(T)(T val){
    static assert(isUnsigned!T, "VarInts do not support signed types!");
    auto result = new ubyte[0];
    while (val){
        T next = val >> 7;
        result ~= cast(ubyte) (val & 127 | (!!next << 7));
        val = next;
    }

    return result;
}
T fromVarInt(T)(in ubyte[] input){
    static assert(isUnsigned!T, "VarInts do not support signed types!");
    T ret = 0;
    ushort offset = 0;
    foreach(ubyte b ; input){
        ret |=  (cast(T)b & 127)  << offset;


        offset+=7;
        assert(offset < T.sizeof*8, "That number is too large. Curruption suspected");

        if (!( b & 128)) break;
    }

    return ret;
}

unittest{
    foreach (uint x ; 0..5000){
        assert(fromVarInt!uint(toVarInt(x)) == x, "VarInt conversion error");
    }
}