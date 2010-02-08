/*
 * Trampoline.s
 * BlockFptr
 *
 * Created by Mike Ash on 2/8/10.
 * Copyright 2010 Rogue Amoeba Software, LLC. All rights reserved.
 */


.globl _Trampoline
_Trampoline:
//    // shuffle return address on stack down by one slot
//    mov (%rsp), %r11
//    mov %r11, -8(%rsp)
//    
//    // spill last register onto stack
//    mov %r9, (%rsp)
//    
//    // shuffle stack pointer down too
//    addq $-8, %rsp
    
    // move ptr-to-block-ptr into r11, dummy value is replaced at runtime
    movabsq $0xdeadbeefcafebabe, %r11
    //movabsq $0x100001130, %r11
    
    mov %r8, %r9
    mov %rcx, %r8
    mov %rdx, %rcx
    mov %rsi, %rdx
    mov %rdi, %rsi
    mov (%r11), %rdi
    mov 16(%rdi), %r11
    jmp *%r11
.globl _TrampolineEnd
_TrampolineEnd:
    .long 0
    .long 0
