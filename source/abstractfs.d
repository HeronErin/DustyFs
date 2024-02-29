module abstractfs;
import freck.streams.streaminterface;


interface FileInterface{
    StreamInterface open();
}
interface DirInterface{
    void tree();
    FileInterface touch(string n, int prealloc = 128);
    DirInterface mkDir(string n);

    import dustyfs.lazyload: UnResolvedLazyloadItem;
    UnResolvedLazyloadItem[] listDir();
}

interface FileSystemInterface{
    DirInterface getRoot();
    void close();
}
 
 
