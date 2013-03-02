import re
import socket
import time
from struct import pack,unpack

def getSocket(chal):
    s=socket.socket()
    s.settimeout(5)
    s.connect(chal)
    return s

def shell(sock):
    command=''
    while(command != 'exit'):
        command=raw_input('$ ')
        sock.send(command)
        time.sleep(.5)
        print sock.recv(0x10000)
    return


def lei(*nums):
	if(len(nums)==1):
		num=nums[0]
		if(num>0):
			if(num<0xffffffff):
				return pack("<I",num)
			else:
				return pack("<Q",num)
		else:
			return pack("<i",num)
	else:
		return ''.join(map(lei,nums))

''' 
utilities
'''
def Alphabet():
    return map (chr, [(lambda x: x+ord('a'))(x) for x in range(0,26)])

def PatternString(): 
    for x in Alphabet(): 
        for y in Alphabet(): 
            for z in range(0,9): 
                yield ''.join([x.upper(), y, str(z)])

def Dipstick(n): 
    limit = 0 
    ret = ''
    for i in PatternString(): 
        if limit < n: 
            limit = limit + 1 
            ret = ret + i 
        else: 
            break 
    return ret 
