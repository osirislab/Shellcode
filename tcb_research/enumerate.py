#!/usr/bin/env python

from struct import pack,unpack
from time import time,sleep
import sys
import pickle
import collections


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

def makePicture(graph,trace):
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

    file_name="prettyPicture.{0}.dot".format(now)
    print "writing {0}".format(file_name)
    g.write_dot(file_name)
    
    
    pickle_file_name="prettyPicture.{0}.pickle".format(now)
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

def doit(eax,trace, size=None):
    """wrapper for enum and makePicture, call from vdb"""
    global graph
    graph={} #this may not be the first time we run doit
    begin=time()
    if size==None:
        size=STRUCT_SIZE
    root=eax
    root=(eax,0) #For consistancy with the rest of the dataset
    enum(root, trace, size)
    makePicture(graph, trace)
    print "finished in {0} seconds".format(time() - begin)



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
    print '{0} paths'.format(len(paths))
    for path in paths:
        print '='*40
        for node in path:
            print '{0} {1}'.format(*map(hex,node))

def view_paths(start,end,graph):
    """wrapper for bfs and parse_paths"""
    paths=bfs(start,end,graph)
    parse_paths(paths)


def get_pointer(addr):
    """returns a dword pointed to by addr"""
    ptr ,= unpack("I",trace.readMemory(addr,POINTER_WIDTH))
    return ptr


####################################################################
#               Everything below here is broken                    #
####################################################################

class BreakOnce(vtrace.Notifier):
    def notify(self, event, trace):
        if(event==vtrace.NOTIFY_BREAK):
            print "hit breakpoint"
            #grab the value in eax it points to the tcb
            tcb = trace.getRegister(REG_EAX)
            enum(tcb,trace)
            makePicture(graph)
        print "notify was called"



def main():
    print '='*80
    print "start"
    print '='*80
    trace=vtrace.getTrace()
    print "got trace"
    trace.execute("tcb")
    print "open"
    myNotifier = BreakOnce()
    trace.registerNotifier(vtrace.NOTIFY_BREAK, myNotifier)
    print "registered notifier"
    trace.run()
    #trace.run()
    #trace.run()
    
    print '='*80
    print "end"
    print '='*80

if __name__ == "__main__":
    main()
