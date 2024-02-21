import std.stdio;
import falloc;
import dustyfs.node;
import freck.streams.memorystream;
import freck.streams.filestream;
import utils;
import dustyfs : DustyFs;

// import tern.typecons;


void main(){
    // 0.toVarInt!uint.fromVarInt!uint.writeln();
    DustyFs dfs = new DustyFs("dustyfs.dust", true);
    // //
    dfs.root.mkDir("Test dirr");
    dfs.root.listDir().writeln();
    dfs.close();
    // ////
    dfs = new DustyFs("dustyfs.dust", false);
    dfs.root.listDir().writeln();
    dfs.close();








}
