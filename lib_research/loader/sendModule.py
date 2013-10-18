#!/usr/bin/env python
from sys import argv
from isis import *

assert(len(argv)>=2)

module_name=argv[1]
module=file(module_name).read()

s=get_socket(('localhost',12345))

s.send(module)


