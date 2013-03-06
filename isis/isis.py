import re
import socket
from struct import pack,unpack

def getSocket(chal):
    s=socket.socket()
    s.settimeout(5)
    s.connect(chal)
    return s

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

