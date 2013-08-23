import re
import socket
import time
from struct import pack,unpack
from string import ascii_lowercase as ALPHABET


def get_socket(chal):
    '''chal is a 2-tuple with an address and a port  ex: ('127.0.0.1',111)'''
    s=socket.socket()
    s.settimeout(5)
    s.connect(chal)
    return s


def shell(sock):
    '''
    pass to this function a socket object with a 
    listening shell(socket reuse)
    '''
    command=''
    while(command != 'exit'):
        command=raw_input('$ ') 
        sock.send(command + '\n')#raw_input won't grab a newline
        time.sleep(.5)
        print sock.recv(0x10000)
    return


def lei(*nums):
    '''
    wrapper for struct.pack(), will guess integer size and type
    takes a variable number of arguments
    '''
    if(len(nums)==1):
        num=nums[0]
        if(num>0):
            if(num<0xffffffff):
                return pack("<I",num) # little-endian, unsigned int
            else:
                return pack("<Q",num) # little-endian, unsigned long long
        else:
            return pack("<i",num) # little-endian int
    else:
        return ''.join(map(lei,nums))


def chunk(iterable, chunk_size):
    '''Divide iterable into chunks of chunk_size'''
    for i in range(0, len(iterable), chunk_size):
        yield iterable[i:i+chunk_size]


def gen_pattern_string(): 
    '''Generator for pattern strings'''
    for x in ALPHABET: 
        for y in ALPHABET: 
            for z in range(10): 
                yield ''.join([x.upper(), y, str(z)])


def pattern_create(n): 
    '''Generate pattern string of n patterns (3 chars) long'''
    limit = 0 
    ret = ''
    for i in gen_pattern_string(): 
        if limit < n: 
            limit = limit + 1 
            ret = ret + i 
        else: 
            break 
    return ret 

MAX_PAT=''.join(gen_pattern_string())

def pattern_offset(offset):
    '''
    Search for offset in pattern string.
    Will accept an int of the form 0x12345678 or a 
    string that looks like '12345678'
    '''
    if(type(offset)==type(999)):
        offset=hex(offset)[2:].zfill(8)
    findMe=reduce(lambda a,b:b+a,chunk(offset,2)).decode('hex')
    return maxPat.index(findMe)