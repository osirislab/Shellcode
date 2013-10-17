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
    cmd="ispoi({0})".format(poi)
    return trace.parseExpression(cmd)


def enum(root,trace,size=None):
    struct_size=size
    if size==None:
	    struct_size=STRUCT_SIZE
    memory=""
    try:
	    memory=trace.readMemory(root[0],struct_size)
    except Exception, err:
	    print "Caught exception: {0}".format(err)
	    memory+='\0'*(struct_size-len(memory))
    
    pointers=unpack("I"*(struct_size/POINTER_WIDTH),memory)
    
    #good_pointers=[i for i in pointers if ispoi(i,trace)]
    

    good_pointers=[(elem,index*POINTER_WIDTH) for elem,index in 
		   zip(pointers,range(len(pointers))) if ispoi(elem,trace)]
    
    if(len(good_pointers)==0):
        return

    #print '{0} pointers'.format(len(good_pointers))

    graph[root[0]]=good_pointers
    for i,offset in good_pointers:
        if(i not in graph):
            enum((i,offset),trace,size)
    return

def doit(eax,trace, size=None):
    global graph
    graph={}
    begin=time()
    if size==None:
        size=STRUCT_SIZE
    root=eax
    root=(eax,0)
    enum(root, trace, size)
    makePicture(graph, trace)
    print "finished in {0} seconds".format(time()-begin)


def bfs(s,e,g):
	q=[]
        #seen=[]
	q.append([(s,0)])
	while(q):
            path=q.pop(0)
            node=path[-1]
            if(node[0]==e):
                return path
            for a in g.get(node[0],[]):
                #if(a in seen):
                #    continue
                #seen.append(a)
                new_path=list(path)
                new_path.append(a)
                q.append(new_path)

def parse_path(path):
    for a,o in path:
        print hex(a),hex(o)

def get_pointer(addr):
    ptr ,= unpack("I",trace.readMemory(addr,4))
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
