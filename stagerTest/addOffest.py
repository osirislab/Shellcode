#!/usr/bin/python

from sys import argv
from struct import pack

if len(argv)!=4:
    print "usage is: %s <offset> <binary> <output>" % argv[0]
    exit(1)

offset,lib,output=argv[1:]

offset  = pack("<I", int(offset,16) + 4)
binary  = file(lib).read()
outFile = file(output, 'w')

outFile.write(offset + binary)
outFile.close()

print "done"
