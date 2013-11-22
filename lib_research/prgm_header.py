#!/usr/bin/env python

from struct import pack,unpack
from sys import argv

def get_entry_point(data):
	offset=0x18
	ep ,= unpack("I",data[offset:offset+4])
	return ep

def get_pgrm_hdr_entry(data,offset):
	type,offset,vaddr,paddr,filesz,memsz,flags,align=(
		unpack("8I",data[offset:offset+8*4]))
	type,offset,vaddr,paddr,filesz,memsz,flags,align=(
		map(hex,(type,offset,vaddr,paddr,filesz,memsz,flags,align)))
	
	print "="*80
	print ("type:{0} \n"
		"offset:{1} \n"
		"vaddr:{2} \n"
		"paddr:{3} \n"
		"filesz:{4} \n"
		"memsz:{5} \n"
		"flags:{6} \n"
		"align:{7} \n").format(type,offset,vaddr,paddr,
				       filesz,memsz,flags,align)

def get_prgm_hdr_offset(data):
	offset=0x1c
	prgm_hdr_offset ,= unpack("I",data[offset:offset+4])
	return prgm_hdr_offset

def get_size_prgm_hdr(data):
	offset=0x2c
	size_prgm_hdr ,= unpack("H",data[offset:offset+2])
	return size_prgm_hdr

def parse_prgm_hdr(data):
	num_entries=get_size_prgm_hdr(data)
	entry_point=get_entry_point(data)
	print "Entry point: {0}".format(hex(entry_point))
	print "{0} entries".format(num_entries)
	for i in range(num_entries):
		prgm_hdr_offset=get_prgm_hdr_offset(data)
		get_pgrm_hdr_entry(data,prgm_hdr_offset+8*4*i)
	


#section name string table offset 
def get_symbols_offset(data):
	e_shstrndx  ,= unpack("H",data[50:50+2])
	e_shoff     ,= unpack("I",data[32:32+4])
	e_shentsize ,= unpack("H",data[46:46+2])
	
	offset=e_shoff+e_shentsize*e_shstrndx
	return offset



def makerwe(data):
	"""make all segments RWE"""
	num_entries=get_size_prgm_hdr(data)
	prgm_hdr_offset=get_prgm_hdr_offset(data)
	for i in range(num_entries):
		
		f_offset = prgm_hdr_offset + 8*4*i
		unpack_target=data[f_offset:f_offset+8*4]
		print "offset{2}, len {0}:\n{1}".format(len(unpack_target),
					     unpack_target.encode('hex'),f_offset)
		
		type,offset,vaddr,paddr,filesz,memsz,flags,align=(
			unpack("8I",unpack_target))
		new_header=pack("8I",
			type,offset,vaddr,paddr,filesz,memsz,7,align)
		#change the flags to be 7 "RWE"
		data=data[:f_offset]+new_header+data[f_offset+len(new_header):]
		print i
	return data
	

if __name__=="__main__":
	f=file(argv[1]).read() 
	#print "Program Header"
	parse_prgm_hdr(f)

	#print '='*80
	#symbols_offset=get_symbols_offset(f)
	if(len(argv)>2):
		if(argv[2]=='--rwe'):
			new_data=makerwe(f)
			file(argv[1]+'.rwe','w').write(new_data)
			
