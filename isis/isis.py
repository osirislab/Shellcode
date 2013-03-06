import re
import socket
import time
from struct import pack,unpack

#chal is a 2-tuple with an address and a port  ex: ('127.0.0.1',111)
def getSocket(chal):
    s=socket.socket()
    s.settimeout(5)
    s.connect(chal)
    return s

#pass to this function a socket object with a listening shell(socket reuse)
def shell(sock):
    command=''
    while(command != 'exit'):
        command=raw_input('$ ') 
        sock.send(command + '\n')#raw_input won't grab a newline
        time.sleep(.5)
        print sock.recv(0x10000)
    return

#wrapper for pack, will guess integer size and type
#takes a variable number of arguments
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
def chunk(iterable, chunkSize):
    for i in range(0,len(iterable),chunkSize):
        yield iterable[i:i+chunkSize]

def alphabet():
    return map (chr, [(lambda x: x+ord('a'))(x) for x in range(0,26)])

def patternString(): 
    for x in alphabet(): 
        for y in alphabet(): 
            for z in range(0,9): 
                yield ''.join([x.upper(), y, str(z)])


def dipstick(n): 
    limit = 0 
    ret = ''
    for i in patternString(): 
        if limit < n: 
            limit = limit + 1 
            ret = ret + i 
        else: 
            break 
    return ret 

maxPat=''.join(patternString())

def rDipstick(offset):
#will accept an int of the form 0x12345678 or a string
#that looks like '12345678'
    if(type(offset)==type(999)):
        offset=hex(offset)[2:].zfill(8)
    findMe=reduce(lambda a,b:b+a,chunk(offset,2)).decode('hex')
    return maxPat.index(findMe)

