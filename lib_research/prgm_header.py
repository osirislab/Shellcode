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
	

if __name__=="__main__":
	f=file(argv[1]).read()
	parse_prgm_hdr(f)
	
