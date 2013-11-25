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
void  patchmygot(void);//noreturn
void  patchmygotpie(void);//noreturn

#endif
