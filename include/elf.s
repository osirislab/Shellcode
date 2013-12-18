%define EI_NIDENT 16

	
;;;  ElfN_Ehdr
%define      e_ident             0
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
%define      e_shstrndx		 50


;;; Elf32_Phdr
%define	  p_type    0
%define   p_offset  4
%define   p_vaddr   8
%define   p_paddr   12
%define   p_filesz  16
%define   p_memsz   20
%define   p_flags   24
%define   p_align   28
           

;;;            Elf32_Shdr
%define   sh_name	0	
%define   sh_type   	4
%define   sh_flags	8
%define   sh_addr	12
%define   sh_offset	16
%define   sh_size	20
%define   sh_link    	24
%define   sh_info	28
%define   sh_addralign	32
%define   sh_entsize	36


;;;  Elf32_Sym
%define         st_name          0
%define         st_value	 4
%define         st_size	         8
%define         st_info	         12
%define         st_other	 13
%define         st_shndx	 14
          

;;; legal values for p_type
%define PT_NULL         0               ; Program header table entry unused 
%define PT_LOAD         1               ; Loadable program segment 
%define PT_DYNAMIC      2               ; Dynamic linking information 
%define PT_INTERP       3               ; Program interpreter 
%define PT_NOTE         4               ; Auxiliary information 
%define PT_SHLIB        5               ; Reserved 
%define PT_PHDR         6               ; Entry for header table itself 
%define PT_TLS          7               ; Thread-local storage segment 
%define PT_NUM          8               ; Number of defined types 
%define PT_LOOS         0x60000000      ; Start of OS-specific 
%define PT_GNU_EH_FRAME 0x6474e550      ; GCC .eh_frame_hdr segment 
%define PT_GNU_STACK    0x6474e551      ; Indicates stack executability 
%define PT_GNU_RELRO    0x6474e552      ; Read-only after relocation 
%define PT_LOSUNW       0x6ffffffa
%define PT_SUNWBSS      0x6ffffffa      ; Sun Specific segment 
%define PT_SUNWSTACK    0x6ffffffb      ; Stack segment 
%define PT_HISUNW       0x6fffffff
%define PT_HIOS         0x6fffffff      ; End of OS-specific 
%define PT_LOPROC       0x70000000      ; Start of processor-specific 
%define PT_HIPROC       0x7fffffff      ; End of processor-specific 


;;; legal values for sh_type
%define SHT_NULL          0             ; Section header table entry unused 
%define SHT_PROGBITS      1             ; Program data 
%define SHT_SYMTAB        2             ; Symbol table 
%define SHT_STRTAB        3             ; String table 
%define SHT_RELA          4             ; Relocation entries with addends 
%define SHT_HASH          5             ; Symbol hash table 
%define SHT_DYNAMIC       6             ; Dynamic linking information 
%define SHT_NOTE          7             ; Notes 
%define SHT_NOBITS        8             ; Program space with no data (bss) 
%define SHT_REL           9             ; Relocation entries, no addends 
%define SHT_SHLIB         10            ; Reserved 
%define SHT_DYNSYM        11            ; Dynamic linker symbol table 
%define SHT_INIT_ARRAY    14            ; Array of constructors 
%define SHT_FINI_ARRAY    15            ; Array of destructors 
%define SHT_PREINIT_ARRAY 16            ; Array of pre-constructors 
%define SHT_GROUP         17            ; Section group 
%define SHT_SYMTAB_SHNDX  18            ; Extended section indeces 
%define SHT_NUM           19            ; Number of defined types.  
%define SHT_LOOS          0x60000000    ; Start OS-specific.  
%define SHT_GNU_ATTRIBUTES 0x6ffffff5   ; Object attributes.  
%define SHT_GNU_HASH      0x6ffffff6    ; GNU-style hash table.  
%define SHT_GNU_LIBLIST   0x6ffffff7    ; Prelink library list 
%define SHT_CHECKSUM      0x6ffffff8    ; Checksum for DSO content.  
%define SHT_LOSUNW        0x6ffffffa    ; Sun-specific low bound.  
%define SHT_SUNW_move     0x6ffffffa
%define SHT_SUNW_COMDAT   0x6ffffffb
%define SHT_SUNW_syminfo  0x6ffffffc
%define SHT_GNU_verdef    0x6ffffffd    ; Version definition section.  
%define SHT_GNU_verneed   0x6ffffffe    ; Version needs section.  
%define SHT_GNU_versym    0x6fffffff    ; Version symbol table.  
%define SHT_HISUNW        0x6fffffff    ; Sun-specific high bound.  
%define SHT_HIOS          0x6fffffff    ; End OS-specific type 
%define SHT_LOPROC        0x70000000    ; Start of processor-specific 
%define SHT_HIPROC        0x7fffffff    ; End of processor-specific 
%define SHT_LOUSER        0x80000000    ; Start of application-specific 
%define SHT_HIUSER        0x8fffffff    ; End of application-specific 
