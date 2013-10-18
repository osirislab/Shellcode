BITS 32
	;; elf header
%define      e_ident		 0
%define      e_type		 16
%define      e_machine		 18
%define      e_version		 20
%define      e_entry		 24
%define      e_phoff		 28
%define      e_shoff		 32
%define      e_flags		 36
%define      e_ehsize		 40
%define      e_phentsize	 42
%define      e_phnum		 44
%define      e_shentsize	 46
%define      e_shnum		 48
%define      e_shstrndx	 	 50



	;; prgm header
%define		p_type    0
%define  	p_offset  4
%define 	p_vaddr   8
%define 	p_paddr   12
%define   	p_filesz  16
%define   	p_memsz   20
%define   	p_flags   24
%define   	p_align   28

	;; section header
%define		sh_name		0	
%define         sh_type   	4
%define   	sh_flags	8
%define 	sh_addr		12
%define  	sh_offset	16
%define   	sh_size		20
%define   	sh_link    	24
%define   	sh_info		28
%define   	sh_addralign	32
%define   	sh_entsize	36


	;; Elf32_Sym
%define		st_name    	0
%define         st_value	4
%define	 	st_size	 	8
%define 	st_info	 	12
%define 	st_other	13
%define      	st_shndx	14
