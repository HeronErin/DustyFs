module dustyfs;

// The filesystem is relatively simple:
// It has a couple types of nodes.
//    * A Directory node
//    * A File node

// Nodes implment a StreamInterface to simplify usage.
//     Nodes are broken up into multiple subNodes.
//
//     The initial node is as following in the file:
//         uint nextprt
//         ushort size of sub node
//         uint size of node (rounded)
//         uint true size of node
//
//     Sub nodes are as follows:
//         uint nextprt
//         ushort size of sub node

public import dustyfs.fs : DustyFs;