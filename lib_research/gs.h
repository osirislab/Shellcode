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

#endif
