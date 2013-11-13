#!/usr/bin/env python

from struct import pack,unpack
from time import time,sleep
import sys
import pickle
import collections
import argparse


STRUCT_SIZE=48
POINTER_WIDTH=4

VDB_ROOT = '/opt/vdb/' #path to vdb folder
VDB_ROOT = '/opt/vivisect_20130901/'

sys.path.append(VDB_ROOT)
try:
    import vtrace
    import vdb
    from envi.archs.i386 import *
except:
    print "There was a problem importing VDB/VTRACE"
    exit(1)
try:
    import pydot
except:
    print "There was a problem importing PYDOT"
    exit(1)

graph={}

def makePicture(graph,trace,filename):
    """Takes a graph populated by enumerate and draws a picture"""
    print "makePicture"
    g=pydot.Dot()
    index=0
    for src,sink in zip(graph.keys(), graph.values()):
        for dest,offset in sink:
            if(ispoi(dest,trace)):
                edge=pydot.Edge(hex(src).strip('L'),hex(dest).strip('L'),
				label='{0}'.format(hex(offset)) )
                g.add_edge(edge)
    
    now=time()

    file_name="{0}.{1}.dot".format(filename,now)
    print "writing {0}".format(file_name)
    g.write_dot(file_name)
    
    
    pickle_file_name="{0}.{1}.pickle".format(filename,now)
    pickle_file=file(pickle_file_name,'w')
    print "writing {0}".format(pickle_file_name)
    pickle.dump(graph,pickle_file)
    pickle_file.close()
    return

def ispoi(poi,trace):
    """return true if poi points to mapped memory"""
    cmd="ispoi({0})".format(poi)
    return trace.parseExpression(cmd)


def enum(root,trace,size=None):
    """DFS through memory seeing what can be reached from root"""
    struct_size=size
    if size==None:
        struct_size=STRUCT_SIZE
    memory=""
    try:
        memory=trace.readMemory(root[0],struct_size)
    except Exception, err:
        #it's possible we're trying to read off the endof an allocation 
        print "Caught exception: {0}".format(err)
        memory+='\0'*(struct_size-len(memory))
        
    pointers=unpack("I"*(struct_size/POINTER_WIDTH),memory)
    
    good_pointers=[(elem,index*POINTER_WIDTH) for elem,index in 
		   zip(pointers,range(len(pointers))) if ispoi(elem,trace)]
    
    if(len(good_pointers)==0):
        return

    graph[root[0]]=good_pointers
    for i,offset in good_pointers:
        if(i not in graph):
            enum((i,offset),trace,size)
    return

def doit(trace, eax, filename, size=None):
    """wrapper for enum and makePicture, call from vdb"""
    global graph
    graph={} #this may not be the first time we run doit
    begin=time()
    if size==None:
        size=STRUCT_SIZE
    root=eax
    root=(eax,0) #For consistancy with the rest of the dataset
    enum(root, trace, size)
    makePicture(graph, trace,filename)
    trace.setMeta("wont_graph",graph)
    print "finished in {0} seconds".format(time() - begin)
    return


def bfs(s,e,g):
    """Breadth First Search. Return all pahs from s(tart) to e(nd) in g"""
    q=[]
    seen=[]
    finished_paths=[]
    q.append([(s,0)])
    while(q):
        path=q.pop(0)
        node=path[-1]
        if(node[0]==e):
            finished_paths.append(path)
        for a in g.get(node[0],[]):
            if(tuple(a) in seen):
                continue
            seen.append(tuple(a))
            new_path=list(path)
            new_path.append(a)
            q.append(new_path)
    return finished_paths

def parse_paths(paths):
    """Helper function, prints paths returned from bfs"""
    print '{0} paths:'.format(len(paths))
    for path,num in zip(paths,range(len(paths))):
        print 'Path {0}'.format(num+1)
        print '='*40
        for node in path:
            print '{0} {1}'.format(*map(hex,node))
    return

def view_paths(start,end,graph):
    """wrapper for bfs and parse_paths"""
    paths=bfs(start,end,graph)
    parse_paths(paths)
    return

def get_pointer(addr):
    """returns a dword pointed to by addr"""
    ptr ,= unpack("I",trace.readMemory(addr,POINTER_WIDTH))
    return ptr


def called_from_vdb(argv):

    parser = argparse.ArgumentParser(description='Look for connections in memory',
                                     epilog="Written by wont for your pleasure.",
                                     prog='enumerate')

    parser.add_argument('--search','-s', nargs=3, metavar=('Root_Addr','Size','Output_prefix'),
                        help='Search memory starting from root with each '
                             '"struct" being n bytes long')                        

    parser.add_argument('--path','-p', nargs=2, metavar=('Start_addr','End_Addr'),
                        help='Find a path between the two nodes. Run after search')


    #parser.add_argument('--help','-h',help='show this help message and exit')


    if 'argv' not in dir():
        argv=sys.argv[1:]
    else:
        argv=argv[1:]

    

    #this is a shitty hack. The argparse handler for help calls exit causing a stacktrace in vdb :(
    if '-h' in argv or '--h' in argv or len(argv)==0: 
        parser.print_help()
        print 
    else:
        args=parser.parse_args(argv)

        

        if args.path<>None and args.search<>None:
            print "Please only use one switch at a time"

        elif args.path<>None:
            #search a path based on the previous path
            start,end = args.path
            start,end = map(eval,[start,end])
            if trace.hasMeta("wont_graph"):
                graph=trace.getMeta("wont_graph")
                view_paths(start,end,graph)
            else:
                print "Run search first"
            
        elif args.search<>None:
            #run path traversal
            root_addr,size,outputFile=args.search
            root_addr,size=map(eval,(root_addr,size))
            doit(trace, root_addr, outputFile, size)


if 'argv' in dir():
    called_from_vdb(argv)


