/*
 * Trampoline.s
 * BlockFptr
 *
 * Created by Mike Ash on 2/8/10.
 * Copyright 2010 Rogue Amoeba Software, LLC. All rights reserved.
 */


#define BLOCK_FUNCTION_POINTER_OFFSET 16

.globl _Trampoline
_Trampoline:
    // shuffle integer argument registers down by one
    // to make room for the implicit block ptr argument
    mov %r8, %r9
    mov %rcx, %r8
    mov %rdx, %rcx
    mov %rsi, %rdx
    mov %rdi, %rsi
    
    
    // move ptr-to-block-ptr into r11, dummy value is replaced at runtime
    movabsq $0xdeadbeefcafebabe, %r11
    // dereference ptr-to-block-ptr, move block ptr into %rdi
    mov (%r11), %rdi
    // extract block implementation function pointer into %r11
    mov BLOCK_FUNCTION_POINTER_OFFSET(%rdi), %r11
    // jump to block implementation
    jmp *%r11
.globl _TrampolineEnd
_TrampolineEnd:
    .long 0
    .long 0
