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

import tern.string : AnsiColor;
import std.conv;
unittest
{
    ulong u = 0;

    // 25 mb of sequential data
    const ubyte[] test_byte_data = (new ubyte[1024*1024*25]).map!(_=>cast(ubyte)(u++ % 0xFF)).array;
    static foreach(openas; [
         "new FileStream(\"speed\", \"w+b\")",
         "new MemoryStream(new ubyte[0])",
         "new NodeStream(new falloc.FileAlloc(new MemoryStream(new ubyte[0]),true))",
         "new NodeStream(new falloc.FileAlloc(new FileStream(\"speed\", \"w+b\"),true))"
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

            writeln(openas ~ ": one-chunk write test Init "
                ~ AnsiColor.BackgroundRed, init_time, AnsiColor.Reset
                ~ " Runtime: "~AnsiColor.BackgroundRed, time_for_write, AnsiColor.Reset
                ~ " at a speed of "~AnsiColor.BackgroundRed,
                cast(real)(test_byte_data.length/1024/1024) / (cast(real)time_for_write.total!"msecs") * 1000, AnsiColor.Reset~" megabytes per secound");
            
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
            writeln(openas ~ ": one-chunk write test Runtime: "~AnsiColor.BackgroundRed, time_for_write, AnsiColor.Reset
            ~ " at a speed of "~AnsiColor.BackgroundRed,
            cast(real)(test_byte_data.length/1024/1024) / (cast(real)time_for_write.total!"msecs") * 1000, AnsiColor.Reset~" megabytes per secound");

            stream.seek(0);
            assert(test_byte_data == stream.read(test_byte_data.length));

            static if (is(typeof(stream) == NodeStream)){
                stream.close();
                stream.allocator.close();
            }

        }

    }}


}