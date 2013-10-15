#!/usr/bin/env python

VDB_ROOT=r'/opt/vdb/' #path to vdb folder
VDB_ROOT=r'/opt/vivisect_20130901/'
from struct import pack,unpack
from time import time,sleep
import sys
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
    for src,sink in zip(graph.keys(),graph.values()):
        for dest in sink:
            if(ispoi(dest,trace)):
                edge=pydot.Edge(hex(src),hex(dest))
                g.add_edge(edge)
    g.write_dot("prettyPicture.{0}.dot".format(time()))
    return

def ispoi(poi,trace):
    cmd="ispoi({0})".format(poi)
    return trace.parseExpression(cmd)

def enum(root,trace):
    struct_size=0x100
    memory=""
    try:
	    memory=trace.readMemory(root,struct_size)
    except Exception, err:
	    print "Caught exception: {0}".format(err)
	    memory+='\0'*(struct_size-len(memory))
	    
    pointers=unpack("I"*(struct_size/4),memory)
    good_pointers=[i for i in pointers if ispoi(i,trace)]
    graph[root]=good_pointers
    for i in good_pointers:
        if(i not in graph):
            enum(i,trace)
    return

def doit(eax,trace):
	enum(eax,trace)
	makePicture(graph,trace)
	


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
