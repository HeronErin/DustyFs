module baseStreamTest;

import freck.streams.streaminterface;

void basicStreamTest(StreamInterface stream){
    assert(stream.read(5) == new ubyte[5]);
    stream.write([1, 2, 3 ,4, 5]);

    assert(stream.read(5) == new ubyte[5]);

    stream.seek(-10, Seek.cur);
    //stream.getContents.writeln();
    assert([1, 2, 3 ,4, 5] == stream.read(5));

    stream.seek(-5, Seek.cur);
    foreach (x ; 1..6)
        assert(stream.read == x);


    auto before = stream.tell();

    foreach (ubyte x ; 57..99)
        stream.write(x);

    stream.seek(before);
    foreach (ubyte x ; 57..99)
        assert(stream.read == x);

    stream.seek(-1, Seek.end);
    stream.write(0x69);
}
