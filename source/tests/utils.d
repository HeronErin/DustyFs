module tests.utils;
import utils;
import std.stdio;


unittest{
    assert(max(9, 10) == 10);
    assert(max(10, 9) == 10);

    assert(min(9, 10) == 9);
    assert(min(10, 9) == 9);
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
    ubyte[] varMem  =toVarInt!uint(69) ~ toVarInt!uint(420) ~ toVarInt!uint(74823) ~ toVarInt!uint(uint.max - 1) ~ toVarInt!uint(128) ~ toVarInt!uint(256) ~ toVarInt!uint(127);
    uint[] d = fromVarIntArray!uint(
        varMem,
        7U
    );
    assert(d == [69, 420, 74823, uint.max - 1, 128, 256, 127], "Failed to read varInts from ubyte[]");
    d = fromVarIntArray!uint(
        varMem,
        6U
    );
    assert(d == [69, 420, 74823, uint.max - 1, 128, 256], "Failed to truncate varInts from ubyte[]");

    import freck.streams.memorystream;
    auto stream = MemoryStream.fromBytes(varMem);
    stream.seek(0);
    d = fromVarIntStream!uint(stream, 7u);
    assert(d == [69, 420, 74823, uint.max - 1, 128, 256, 127], "Failed to read varInts from stream]");
    stream.seek(0);
    d = fromVarIntStream!uint(stream, 6u);
    assert(d == [69, 420, 74823, uint.max - 1, 128, 256], "Failed to truncate varInts from stream");

    "Passed multiple varInt test".writeln();
}