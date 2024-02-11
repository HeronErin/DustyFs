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