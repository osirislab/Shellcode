#!/usr/bin/python

import sys, ctypes
from struct import *

from elftools.elf.elffile import ELFFile
from elftools.elf.descriptions import (
    describe_ei_class, describe_ei_data, describe_ei_version,
    describe_ei_osabi, describe_e_type, describe_e_machine,
    describe_e_version_numeric, describe_p_type, describe_p_flags,
    describe_sh_type, describe_sh_flags,
    describe_symbol_type, describe_symbol_bind, describe_symbol_visibility,
    describe_symbol_shndx, describe_reloc_type,
    )

def main():
	if(len(sys.argv)!=3):
		print "Usage: %s <ELF filename> <output filename>" % sys.argv[0]
		return	
	
	print "Opening ELF file: %s" % sys.argv[1] 
	elffile = ELFFile(open(sys.argv[1],'r'))
	header = elffile.header
	
	print "Entry point: 0x%x" % header['e_entry']
		
	loadsegments = list()
	for segment in elffile.iter_segments():
		segtype = describe_p_type(segment['p_type'])
		segtype + " " + str(segment)
		if(segtype=="LOAD"):
			loadsegments.append(segment)
			
	imgsize = 0
	for segment in loadsegments:
		if(elffile.elfclass == 32):
			print "Load offset " + str(describe_p_flags(segment['p_flags'])) + \
			" 0x%08x at 0x%08x, align 0x%0x" % \
			(segment['p_offset'], segment['p_vaddr'], segment['p_align'])
		else:
			print "Load offset " + str(describe_p_flags(segment['p_flags'])) + \
			" 0x%016x at 0x%016x, align 0x%0x" % \
			(segment['p_offset'], segment['p_vaddr'], segment['p_align'])		
		print "\tFile size: 0x%x\tMem size: 0x%x" % (segment['p_filesz'], segment['p_memsz'])
		imgsize = max(imgsize,segment['p_vaddr']+segment['p_memsz'])
	print "Image size: 0x%x" % imgsize 
	
	buf = ctypes.create_string_buffer(imgsize)
	for segment in loadsegments:
		offset = segment['p_vaddr']
		data = segment.data()
		for i in range(len(segment.data())):
			pack_into('c',buf,offset+i,data[i])
	
	outfile = file(sys.argv[2],'w')
	for char in buf:
		outfile.write(char)
		
#-------------------------------------------------------------------------------
if __name__ == '__main__':
    main()
