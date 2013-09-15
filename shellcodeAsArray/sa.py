#!/usr/bin/env python

from sys import argv

shellcode=file(argv[1]).read()
h=map(lambda a:a[2:].zfill(2),map(hex,map(ord,shellcode)))
print r'\x'.join(h)
