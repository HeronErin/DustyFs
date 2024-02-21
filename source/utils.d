/+  This file is a part of DustyFs, a free backup utility/filesystem.

    Copyright (C) 2024 - HeronErin

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
        (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
+/
module utils;

public enum Endianness
{
    Native,
    LittleEndian,
    BigEndian
}
import std.algorithm.mutation;
import freck.streams.streaminterface;

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
        debug assert(offset < T.sizeof*8, "That number is too large. Curruption suspected");
        ret |=  (cast(T)b & 127)  << offset;

        offset+=7;
        if (0 == (b & 128) ) break;
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

        if (0 == (b & 128) ) {
            result ~= ret;
            ret = 0;
            offset = 0;
            if (0 == --size) break;
        }

    }

    return result;
}

T[] fromVarIntStream(T)(StreamInterface si, uint size){
    auto result = new T[0];

    T ret = 0;
    ushort offset = 0;
    while (size){
        ubyte b = si.read();
        debug assert(offset < T.sizeof*8, "That number is too large. Curruption suspected");
        ret |=  (cast(T)b & 127)  << offset;
        offset+=7;
        if (0 == (b & 128) ) {
            result ~= ret;
            ret = 0;
            offset = 0;
            if (0 == --size) break;
        }
    }
    return result;

}

T readInt(T)(StreamInterface si){
    ubyte[] readData = si.read(T.sizeof);
    //import std.conv;
    assert( readData.length == T.sizeof, "readInt() failed due it insufficient file size!");

    T val = ( cast(T[]) readData)[0];
    val = utils.fromEndian!T(val, utils.Endianness.LittleEndian);
    return val;
}

void writeInt(T)(StreamInterface si, T val){
    val = utils.toEndian!T(val, utils.Endianness.LittleEndian);
    ubyte[] next = (cast(ubyte*)&val)[0..T.sizeof];
    si.write(next);
}



