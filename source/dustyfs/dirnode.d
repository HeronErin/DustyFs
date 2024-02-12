module dustyfs.dirnode;


import dustyfs.node;
import dustyfs.fs;

interface NodeWithMetadata{
    bool isDirty();
    void write();

}


class DirNode : NodeWithMetadata{
    protected DustyFs parent;
    protected NodeStream nodeWriter;

    protected bool dirty = false;
    bool isDirty() => this.dirty;



    this(DustyFs parent, uint reserveSize = 1024){
        this.parent = parent;
        this.nodeWriter = new NodeStream(parent, reserveSize);

        this.dirty = true;
    }
    this(DustyFs parent, uint offset, uint endingOffset){
        this.parent = parent;
        this.nodeWriter = new NodeStream(parent, offset, endingOffset);

        this.dirty = false;
    }
    void write(){

    }






}