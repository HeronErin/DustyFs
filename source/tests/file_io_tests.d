module filetests;
import std.stdio;
import falloc;
import freck.streams.filestream;

import betterMemoryStream;

static import core.exception;

import freck.streams.streaminterface;

// Test basic falloc usage
unittest{
    foreach(StreamInterface sourceStream ; [
        cast(StreamInterface) new FileStream("basic.dust", "w+b"),
        cast(StreamInterface) new MemoryStream(new ubyte[0])
        ]){
            auto allocator = new falloc.FileAlloc(sourceStream, true);

            assert(25 == allocator.alloc(0));
            assert(30 == allocator.alloc(0));
            assert(35 == allocator.alloc(0));

            allocator.free(25);
            assert(25 == allocator.alloc(0));

            assert(40 == allocator.alloc(100));
            assert(145 == allocator.alloc(0));


            try{
                allocator.alloc(falloc.DEFAULT_SECTION_SIZE);
            }
            catch (core.exception.AssertError e){
                /* This is intended behavior! */
                goto GOOD;
            }
            assert(0, "falloc did not throw an assertion error when allocing too much!");
            GOOD:

            assert(150 == allocator.alloc(5*1024*1024));
            assert(10485797 == allocator.alloc(5*1024*1024));

            allocator.close();
    }

}


// Opening a pre-written file test
unittest{

    auto allocator = new falloc.FileAlloc(new FileStream("reopen.dust", "wb+"), true);
    assert(25 == allocator.alloc(100));

    allocator.close();


    allocator = new falloc.FileAlloc(new FileStream("reopen.dust", "rb+"), false);
    assert(130 == allocator.alloc(100));

    allocator.close();
}

