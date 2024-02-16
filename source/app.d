import std.stdio;
import falloc;
import freck.streams.filestream;
import utils;
import dustyfs : DustyFs;

import caiman.typecons;


void main(){
    DustyFs dfs = new DustyFs("dustyfs.dust", true);
    dfs.root.mkDir("Test dirr");
    dfs.close();

    dfs = new DustyFs("dustyfs.dust", false);
    dfs.root.listDir().writeln();
    dfs.close();







}
