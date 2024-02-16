module tests.dustyfs_test;
import dustyfs.fs : DustyFs;
import std.stdio;

unittest{
    DustyFs dfs = new DustyFs("dustyfs.dust", true);
    scope (exit) dfs.close();
}