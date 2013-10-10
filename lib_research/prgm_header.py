def get_pgrm_hdr_entry(data,offset):
	type,offset,vaddr,paddr,filesz,memsz,flags,align=unpack("8I",data[offset:offset+8*4])
	type,offset,vaddr,paddr,filesz,memsz,flags,align=map(hex,(type,offset,vaddr,paddr,filesz,memsz,flags,align))
	print ("type:{0} \n"
		"offset:{1} \n"
		"vaddr:{2} \n"
		"paddr:{3} \n"
		"filesz:{4} \n"
		"memsz:{5} \n"
		"flags:{6} \n"
		"align:{7} \n").format(type,offset,vaddr,paddr,filesz,memsz,flags,align)

def get_prgm_hdr_offset(data):
	offset=0x1c
	prgm_hdr_offset ,= unpack("I",data[offset:offset+4)
	return prgm_hdr_offset

def get_size_prgm_hdr(data):
	offset=0x2a
	size_prgm_hdr ,= unpack("H",data[offset:offset+2])
	return size_prgm_hdr

def parse_prgm_hdr(data):
	for i in range(get_size_prgm_hdr(data)):
		prgm_hdr_offset=get_prgm_hdr_offset(data)
		get_pgrm_hdr_entry(data,prgm_hdr_offset+8*4*i)

