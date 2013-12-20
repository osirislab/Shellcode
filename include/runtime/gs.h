#ifndef gs
#define gs

void* getTLS(void);
void* getLibc(void);
void* gettextload(void);
void* getCode(void);
void* getpieload(void);
void* getStringIndex(void);
void* getgotzero(void);
void* getgotone(void);
void* getgottwo(void);
void* findelfheader(void);
void* findgotpie(void);
void* findgot(void);
void  patchmygot(void);//noreturn
void  patchmygotpie(void);//noreturn
void  fixdynamicpie(void);
void* find_loader_by_place(void);
void* find_loader_by_name(void);
void* find_symtab(void* module_base);
void  start_main_wrapper(int (*function)(void));
void  start_main_wrapper_alt(int (*function)(void));
void  do_patch_pie(void);
void  patch_l_info(void);
/*
int (*)(int (*main_func) (int, char * *, char * *),
       int argc,
       char * * ubp_av,
       void (*init_func) (void),
       void (*fini_func) (void),
       void (*rtld_fini_func) (void),
       void (* stack_end)) get_libc_start_main(void);
*/
void* get_libc_start_main(void);

#endif
