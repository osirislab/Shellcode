#!/usr/bin/env python

from sys import argv

def main():
    shellcode=file(argv[1]).read()
    binary_String = (r'\x'+
                     r'\x'.join(map( lambda a:a.encode('hex'),
                                     shellcode
                                     )
                                )
                     )
    print binary_String



if __name__=='__main__':
    if len(argv)<2 :
        print "usage is %s <shellcode>" % argv[0]
        exit(1)

    main()
