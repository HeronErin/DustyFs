module filetests;
import std.stdio;
import falloc;
import freck.streams.filestream;

// Test basic falloc usage
unittest{
    auto allocator = new falloc.FileAlloc(new FileStream("basic.dust", "w+b"), true);

    assert(25 == allocator.alloc(0));
    assert(30 == allocator.alloc(0));
    assert(35 == allocator.alloc(0));

    allocator.free(25);
    assert(25 == allocator.alloc(0));

    assert(40 == allocator.alloc(100));
    assert(145 == allocator.alloc(0));


    try{ allocator.alloc(falloc.DEFAULT_SECTION_SIZE); }
    catch (core.exception.AssertError e){
        /* This is intended behavior! */
        goto GOOD;
    }
    assert(0, "falloc did not throw an assertion error when allocing too much!");
    GOOD:

    assert(150 == allocator.alloc(5*1024*1024));
    assert(10485797 == allocator.alloc(5*1024*1024));

    //"Finished basic usage test".writeln();
    //allocator.printAllocTree();
}


// Reopening falloc file
unittest{

    auto allocator = new falloc.FileAlloc(new FileStream("reopen.dust", "wb+"), true);
    assert(25 == allocator.alloc(100));
    allocator.destroy();


    allocator = new falloc.FileAlloc(new FileStream("reopen.dust", "rb+"), false);
    assert(130 == allocator.alloc(100));


    //allocator.alloc(100).writeln();
}