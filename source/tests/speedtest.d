module tests.speedtest;

import betterMemoryStream;
import freck.streams.filestream;
import freck.streams.streaminterface;
import std.datetime;

import std.algorithm;
import std.stdio;
import std.array;

import tern.typecons;
import falloc;
import dustyfs.node;
unittest
{
    ulong u = 0;

    // 25 mb of sequential data
    const ubyte[] test_byte_data = (new ubyte[1024*1024*20]).map!(_=>cast(ubyte)(u++ % 0xFF)).array;
    static foreach(openas; [
        "new FileStream(\"speed\", \"w+b\")",
        "new MemoryStream(new ubyte[0])",
        "new NodeStream(new falloc.FileAlloc(new MemoryStream(new ubyte[0]),true))"
        ]){{
        // One large chunck
        {   
            auto init_start = Clock.currTime();
            auto stream = mixin(openas);
            auto init_time = Clock.currTime() - init_start;

            auto write_start = Clock.currTime();
            stream.write(test_byte_data);
            auto time_for_write = Clock.currTime() - write_start;

            stream.seek(0);
            assert(test_byte_data == stream.read(test_byte_data.length));

            writeln(openas ~ ": one-chunk write test Init: ", init_time, " Runtime: ", time_for_write);
            
            static if (is(typeof(stream) == NodeStream)){
                stream.close();
                stream.allocator.close();
            }
        }
        // Many writes
        {
            auto stream = mixin(openas);

            auto write_start = Clock.currTime();
            foreach(i; 0..test_byte_data.length){
                stream.write(test_byte_data[i]);
            }
            auto time_for_write = Clock.currTime() - write_start;
            writeln(openas ~ ": many-writes runtime: ", time_for_write);

            static if (is(typeof(stream) == NodeStream)){
                stream.close();
                stream.allocator.close();
            }

        }

    }}


}