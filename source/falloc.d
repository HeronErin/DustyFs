module falloc;
import freck.streams.streaminterface;
import std.stdio;
import std.string : StringException;
import std.typecons;

import utils;

enum HEADER_STRING = "DustyFs\n";
enum SIZE_OF_HEADER_STRING = HEADER_STRING.length;
enum SIZE_OF_SECTION_HEADER = uint.sizeof*3;
enum SIZE_OF_CHUNCK_HEADER = uint.sizeof + bool.sizeof;
enum DEFAULT_SECTION_SIZE = 1024*1024*10; // 10 mb
enum MAX_DEFAULT_ALLOC_SIZE = DEFAULT_SECTION_SIZE - SIZE_OF_SECTION_HEADER - SIZE_OF_CHUNCK_HEADER;

enum FIRST_CHUNCK = SIZE_OF_HEADER_STRING+SIZE_OF_SECTION_HEADER;


// Dusty fs chuck alloccation specification:

// Starts with a header string of "DustyFs\n"
// All numbers are stored as little endian.


// Then made up of segments of N size. If N is zero, the segments from that point will be reinitalized.
// size of segment (N)        as uint
// space used                 as uint
// smallest failed allocation as uint and defaults to uint.max


// Segments are made out of chuncks:

// Next chunck offset (relative to start of file) as uint
// Boolean for if a chunck is free                as bool


import std.math;



class FileAlloc{
    StreamInterface file;
    protected Section[] sections;

    void writeInt(T)(T val){
        val = utils.toEndian!T(val, utils.Endianness.LittleEndian);
        ubyte[] next = (cast(ubyte*)&val)[0..T.sizeof];
        file.write(next);
    }
    T readInt(T)(){
        ubyte[] readData = file.read(T.sizeof);
        import std.conv;
        assert( readData.length == T.sizeof, "readInt() failed due it insufficient file size!");

        T val = ( cast(T[]) readData)[0];
        val = utils.fromEndian!T(val, utils.Endianness.LittleEndian);
        return val;
    }
    protected T readIntFromBytes(T)(in ubyte[] readData){

        assert( readData.length == T.sizeof, "readIntFromBytes() failed due it insufficient file size!");

        T val = ( cast(T[]) readData)[0];
        val = utils.fromEndian!T(val, utils.Endianness.LittleEndian);
        return val;
    }


    protected void writeChunckHeader(uint nextprt, bool isFree){
        writeInt(nextprt);
        writeInt(isFree);
    }
    protected Tuple!(uint, bool) readChunckHeader(){
        return tuple(readInt!uint(), readInt!bool());
    }

    protected Tuple!(uint, uint, uint) readSectionHeader(){
        return tuple(
            readInt!uint(),
            readInt!uint(),
            readInt!uint()
        );
    }

    protected struct Section{
        FileAlloc parent;
        uint offset;

        uint size;
        uint spaceUsed;
        uint largestFailedAlloc;

        void write(){
            parent.file.seek(offset);
            parent.writeInt(size);
            parent.writeInt(spaceUsed);
            parent.writeInt(largestFailedAlloc);
        }
    }



    this(StreamInterface file, bool doInit=false){
        this.file=file;
        file.seek(0);



        const auto from_file = file.read(SIZE_OF_HEADER_STRING);
        if (from_file == HEADER_STRING){
            "Header found".writeln();
            uint pos = SIZE_OF_HEADER_STRING;
            while(1){
                Tuple!(uint, uint, uint) section = readSectionHeader();
                Section current;

                current.parent=this;
                current.offset = pos;
                if (!current.size) break;
                current.size               = section[0];
                current.spaceUsed          = section[1];
                current.largestFailedAlloc = section[2];
                sections ~= current;

                pos += SIZE_OF_SECTION_HEADER + current.size;

                file.seek(pos);
                //if (pos+SIZE_OF_SECTION_HEADER > file.length()) return;

            }
        }else if (doInit){
            "Creating header".writeln();
            file.write(cast(ubyte[]) HEADER_STRING);

            Section firstSection;
            firstSection.parent=this;
            firstSection.offset = SIZE_OF_HEADER_STRING;

            firstSection.largestFailedAlloc = uint.max;
            firstSection.spaceUsed = 0;
            firstSection.size = DEFAULT_SECTION_SIZE;

            sections ~= firstSection;

            file.seek(FIRST_CHUNCK);

            writeChunckHeader(0, true);
        }
        else
            throw new StringException("File either corrupt or not found. Please set doInit to true.");

    }
    ~this(){
        foreach (ref section ; this.sections){
            section.write();
        }
    }
    uint alloc(uint size, bool recursion=false){

        assert(size <= MAX_DEFAULT_ALLOC_SIZE, "Too large allocation");

        foreach(ref section ; sections){
            assert(section.size >= section.spaceUsed, "Section has too much data allocated");

            const uint avalible = utils.min(section.size-section.spaceUsed, section.largestFailedAlloc) ;
            if (avalible < size + SIZE_OF_CHUNCK_HEADER) { section.largestFailedAlloc=size; continue; }

            file.seek(section.offset + SIZE_OF_SECTION_HEADER);

            while (1){
                Tuple!(uint, bool) chunckHeader = readChunckHeader();
                uint nextPrt = chunckHeader[0];
                bool isFree = chunckHeader[1];

                if (!isFree){
                    if (nextPrt == 0) {section.largestFailedAlloc=0; break;}
                    file.seek(nextPrt);
                    continue;
                }
                if (nextPrt == 0 && size > section.size + section.offset - file.tell()){
                    section.largestFailedAlloc=size; break;
                }

                auto chunckSize = nextPrt == 0 ? section.size + section.offset - file.tell() : nextPrt - file.tell();

                section.spaceUsed+=size;

                file.seek(file.tell()-SIZE_OF_CHUNCK_HEADER);
                uint pos = cast(uint) file.tell();

                // Fill entire chunck
                if (chunckSize == size || (cast(int)( chunckSize-size )) < SIZE_OF_CHUNCK_HEADER){
                    writeChunckHeader(nextPrt, false);
                    return pos+cast(uint)SIZE_OF_CHUNCK_HEADER;
                }


                // Split chunck

                uint newNextPrt = pos+size + (cast(uint)SIZE_OF_CHUNCK_HEADER);
                writeChunckHeader(newNextPrt, false);
                file.seek(newNextPrt);
                writeChunckHeader(nextPrt, true);


                return pos+cast(uint)SIZE_OF_CHUNCK_HEADER;
            }

            section.largestFailedAlloc=size;

        }

        assert(!recursion, "Attempted to create a section after creating a section!");


        const auto lastSection = sections[$-1];

        auto nextSection = lastSection.size + lastSection.offset + SIZE_OF_SECTION_HEADER;


        Section section;
        section.parent=this;
        section.offset = cast(uint)nextSection;

        section.largestFailedAlloc = uint.max;
        section.spaceUsed = 0;
        section.size = DEFAULT_SECTION_SIZE;
        section.write();

        writeChunckHeader(0, true);

        sections ~= section;


        return alloc(size, true);
    }


    void free(uint ptr){
        if (ptr == -1) throw new StringException("Invalid pointer (from failure of alloc)");
        file.seek(ptr-1);
        const auto isFreeByte = readInt!ubyte();
        assert(isFreeByte==0 || isFreeByte==1, "Invalid pointer (file position is not same as returned by alloc)");

        file.seek(ptr-SIZE_OF_CHUNCK_HEADER);

        auto chunckHeader = readChunckHeader();
        auto nextPtr = chunckHeader[0];
        while(chunckHeader[1] == true){
            chunckHeader = readChunckHeader();
            if (chunckHeader[1]) {
                nextPtr=chunckHeader[0];
                continue;
            }
            break;
        }

        file.seek(ptr-SIZE_OF_CHUNCK_HEADER);
        writeChunckHeader(nextPtr, true);
    }

    void printAllocTree(){
        "Sections: ".writeln();
        int index = 0;
        foreach (ref section ; sections ){
            writeln(++index, ". Offset:", section.offset, ", Of size:", section.size,  ", Space used:", section.spaceUsed, ", Largest fail: ", section.largestFailedAlloc);


            uint ptr = section.offset+cast(int)SIZE_OF_SECTION_HEADER;
            while(ptr != 0){
                file.seek(ptr);
                auto chunckHeader = readChunckHeader();

                writeln("| at ",ptr, ": ", chunckHeader[1] ? "not used" : "used");
                ptr = chunckHeader[0];
            }
        }

    }
}
