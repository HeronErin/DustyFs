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
    static assert(false == isFloatingPoint!T, "VarInts do not support floating point types");
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
    static assert(false == isFloatingPoint!T, "VarInts do not support floating point types");
    static assert(isUnsigned!T, "VarInts do not support signed types!");

    T ret = 0;
    ushort offset = 0;
    foreach(ubyte b ; input){
        debug assert(offset < T.sizeof*8, "That number is too large. Curruption suspected");f
        ret |=  (cast(T)b & 127)  << offset;

        offset+=7;
        if (!( b & 128)) break;
    }

    return ret;
}

T[] fromVarIntArray(T)(in ubyte[] input, uint size){
    static assert(false == isFloatingPoint!T, "VarInts do not support floating point types");
    static assert(isUnsigned!T, "VarInts do not support signed types!");
    auto result = new T[0];

    T ret = 0;
    ushort offset = 0;
    foreach(ubyte b ; input){
        debug assert(offset < T.sizeof*8, "That number is too large. Curruption suspected");

        ret |=  (cast(T)b & 127)  << offset;
        offset+=7;

        if (!( b & 128)) {
            result ~= ret;
            ret = 0;
            offset = 0;
        }
    }




    return result;
}

unittest{
    foreach (uint x ; 0..5000){
        assert(fromVarInt!uint(toVarInt(x)) == x, "VarInt conversion error");
    }
    foreach (ushort x ; 1..64){
        ulong testBase = 1 << x;
        assert(fromVarInt!ulong(toVarInt!ulong(testBase)) == testBase, "VarInt conversion error");
        foreach (ulong y ; 0..5000){
            assert(fromVarInt!ulong(toVarInt(y+testBase)) == y+testBase, "VarInt conversion error");
        }
    }

    assert(fromVarInt!uint(toVarInt(uint.max - 1)) == uint.max - 1, "VarInt conversion error");
    assert(fromVarInt!uint(toVarInt(uint.max)) == uint.max, "VarInt conversion error");
    "Passed varint test".writeln();
}

unittest{
    uint[] d = fromVarIntArray!uint(
        toVarInt!uint(69) ~ toVarInt!uint(420) ~ toVarInt!uint(74823) ~ toVarInt!uint(uint.max - 1) ~ toVarInt!uint(128) ~ toVarInt!uint(256) ~ toVarInt!uint(127),
        4U
    );
    assert(d == [69, 420, 74823, uint.max - 1, 128, 256, 127]);
    "Passed multiple varInt test".writeln();
}