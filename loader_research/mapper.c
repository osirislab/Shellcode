#define _POSIX_C_SOURCE 200112
#define _GNU_SOURCE

#include "sys/mman.h"
#include "fcntl.h"
#include "stdlib.h"
#include "string.h"
#include "stdio.h"
#include "unistd.h"
#include "sys/stat.h"
#include "elf.h"
#include "signal.h"
//#include "proc/libproc.h"

#define USERLAND 0xc0000000

//Take alignment into account!

#define ALIGN(addr, pgsz) (void*) ((size_t)(addr) & ~((size_t)(pgsz) - 1))
#define ALIGNSZ(addr, sz, pgsz) ((size_t)(sz) + (size_t)(addr) % (size_t)(pgsz))

void p_ehdr(Elf32_Ehdr *e) {
    printf("Elf32_Ehdr\n");
    printf("    e_type: %x\n", e->e_type);
    printf("    e_machine: %x\n", e->e_machine);
    printf("    e_version: %x\n", e->e_version);
    printf("    e_entry: %x\n", e->e_entry);
    printf("    e_phoff: %x\n", e->e_phoff);
    printf("    e_shoff: %x\n", e->e_shoff);
    printf("    e_flags: %x\n", e->e_flags);
    printf("    e_ehsize: %x\n", e->e_ehsize);
    printf("    e_phentsize: %x\n", e->e_phentsize);
    printf("    e_phnum: %x\n", e->e_phnum);
    printf("    e_shentsize: %x\n", e->e_shentsize);
    printf("    e_shnum: %x\n", e->e_shnum);
    printf("    e_shstrndx: %x\n", e->e_shstrndx);
    printf("\n");
}

void p_phdr(Elf32_Phdr* p) {
    printf("Elf32_Phdr\n");
    printf("    p_type: %x\n", p->p_type);
    printf("    p_offset: %x\n", p->p_offset);
    printf("    p_vaddr: %x\n", p->p_vaddr);
    printf("    p_paddr: %x\n", p->p_paddr);
    printf("    p_filesz: %x\n", p->p_filesz);
    printf("    p_memsz: %x\n", p->p_memsz);
    printf("    p_flags: %x\n", p->p_flags);
    printf("    p_align: %x\n", p->p_align);
    printf("\n");
}

void p_shdr(Elf32_Shdr* s) {
    printf("Elf32_Shdr\n");
    printf("    sh_name: %x\n", s->sh_name);
    printf("    sh_type: %x\n", s->sh_type);
    printf("    sh_flags: %x\n", s->sh_flags);
    printf("    sh_addr: %x\n", s->sh_addr);
    printf("    sh_offset: %x\n", s->sh_offset);
    printf("    sh_size: %x\n", s->sh_size);
    printf("    sh_link: %x\n", s->sh_link);
    printf("    sh_info: %x\n", s->sh_info);
    printf("    sh_addralign: %x\n", s->sh_addralign);
    printf("    sh_entsize: %x\n", s->sh_entsize);
    printf("\n");
}

int main(int argc,char** argv) {
    int pgsz = getpagesize();
    int pgnum = USERLAND / pgsz;
    
    int fd = open(( 1<argc ? argv[1] : "input.so"), O_RDONLY);

    if(fd == -1) {
        perror(NULL);
        exit(10);
    }

    struct stat st_fd;
    if(fstat(fd, &st_fd) == -1) {
        perror(NULL);
        exit(11);
    }

    // mmap entire file into memory. IN our loader, we just load into memory somewhere!
    void* mem = mmap(NULL, st_fd.st_size, PROT_EXEC | PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);

    if(mem == MAP_FAILED) {
        perror(NULL);
        exit(12);
    }

    Elf32_Ehdr* ehdr = mem;
    p_ehdr(ehdr);

    Elf32_Shdr* strtab = mem + ehdr->e_shoff + ehdr->e_shstrndx * ehdr->e_shentsize;
    Elf32_Phdr* dynamic = NULL;
    Elf32_Shdr* got_plt = NULL;
    void* base = (void*) 0x40000000;

    // create the memory segments
    for(size_t i = 0; i < ehdr->e_phnum; ++i) {
        Elf32_Phdr* phdr = mem + ehdr->e_phoff + ehdr->e_phentsize * i;

        // don't touch GNU extensions... yet! (And we probably don't need to, we already have a stack)
        switch(phdr->p_type) {
            case PT_NULL: break;
            case PT_DYNAMIC:
                dynamic = phdr;
            case PT_LOAD:
            case PT_INTERP:
            case PT_NOTE:
            case PT_SHLIB:
            case PT_PHDR:
            case PT_LOPROC:
            case PT_HIPROC: {
                void* segment = mmap(ALIGN(base + phdr->p_vaddr, pgsz),
                    ALIGNSZ(base + phdr->p_vaddr, phdr->p_memsz, pgsz),
                    PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED, -1, 0
                );

                printf("Segment: %p : %p : %p %x\n",
                    segment, ALIGN(base + phdr->p_vaddr, pgsz), (void*)phdr->p_memsz, phdr->p_flags);

                if(segment == MAP_FAILED) perror(NULL);
                break;
            }         
            default: break;
        }
    }

    if(dynamic == NULL) {
        fprintf(stderr, "No dynamic segment!\n");
        exit(15);
    }

    for(size_t i = 0; i < ehdr->e_shnum; ++i) {
        Elf32_Shdr* shdr = mem + ehdr->e_shoff + ehdr->e_shentsize * i;

        switch(shdr->sh_type) {
            case SHT_NULL: break;
            case SHT_NOBITS: printf("NOBITS\n"); break;
            case SHT_PROGBITS:
            case SHT_SYMTAB:
            case SHT_STRTAB:
            case SHT_RELA:
            case SHT_HASH:
            case SHT_DYNAMIC:
            case SHT_NOTE:
            case SHT_REL:
            case SHT_SHLIB:
            case SHT_DYNSYM:
            case SHT_LOPROC:
            case SHT_HIPROC:
            case SHT_LOUSER:
            case SHT_HIUSER: {
                if(shdr->sh_addr == 0) continue;
                printf("%s\tmemcpy(%p, %p, %x)\n",
		       (char*)(mem + strtab->sh_offset + shdr->sh_name),
                    (base + shdr->sh_addr),
                    (mem + shdr->sh_offset),
                    shdr->sh_size
                );

                if(strcmp(mem + strtab->sh_offset + shdr->sh_name, ".got.plt") == 0)
                    got_plt = shdr;

                memcpy(base + shdr->sh_addr, mem + shdr->sh_offset, shdr->sh_size);
                break;
            }
            default: break;
        }
    }

    if(got_plt == NULL) {
        fprintf(stderr, "No got.plt section!\n");
        exit(16);
    }

    // create the memory segments
    for(size_t i = 0; i < ehdr->e_phnum; ++i) {
        Elf32_Phdr* phdr = mem + ehdr->e_phoff + ehdr->e_phentsize * i;

        switch(phdr->p_type) {
            case PT_NULL: break;
            case PT_LOAD:
            case PT_DYNAMIC:
            case PT_INTERP:
            case PT_NOTE:
            case PT_SHLIB:
            case PT_PHDR:
            case PT_LOPROC:
            case PT_HIPROC: {
                if(mprotect(ALIGN(base + phdr->p_vaddr, pgsz),
                    ALIGNSZ(base + phdr->p_vaddr, phdr->p_memsz, pgsz),
                    phdr->p_flags
                ) == -1) {
                    perror(NULL);
                    exit(14);
                }
            }         
            default: break;
        }
    }

    //Parse the dynamic junk... TODO: THAT SIZE IS 10, YOU MORON
    for(size_t i = 0; i < 10; ++i) {
        Elf32_Dyn* dyn = mem + dynamic->p_offset + sizeof(Elf32_Dyn) * i;

        printf("ELEM: %x\n", dyn->d_tag);
    }

    size_t got_sz = got_plt->sh_size / sizeof(void*) - 3;

    //Do some remapping
    for(size_t i = 0; i < got_sz; ++i) {
      void** addr = base + got_plt->sh_addr + (3 + i) * sizeof(void*);
        *addr = (size_t)(*addr)+ (size_t)base;
    }

    printf("End!\n");
    printf("INIT: %p\n", base + ehdr->e_entry);

    void (*ep)() = base + 0x3d0;
    void (*init)() = base + ehdr->e_entry;
    void (*f)() = base + 0x4b2; // 0x22a86; //ehdr->e_entry + 0xbc;
    
    //raise(SIGINT);
    printf("ep: %p\n",ep);
    printf("init: %p\n",init);
    printf("f: %p\n",f);
    //ep();
    printf("EP OK\n");
    init();
    printf("INIT OK\n");
    f();
    
    printf("YAY\n");

    return 0;
}
