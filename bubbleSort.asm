BITS 64 ; set machine code to 64 bits processor to use 64-bit registers like rax, rsi, and use 64-bit memory addressing
extern ExitProcess ; import ExitProcess function from the windows kernel32
extern printf ; import printf function from C library
global main ; make the "main" label the entry point of the program
default rel ; make the CPU calculate the address from the RIP (Instruction Pointer) instead of looking for a fixed memory location

section .data
        list DB 25,24,26,28,22,20 ; create an array of 1 byte (0 - 255) values
        list_size equ $ - list ; subtracts the current memory address with the address of the first element of list = size of array in bytes
        ; equ works like a #define, it overwrite list_size to a value at compile time
        element_string db "%u ",0 ; the string we will pass to printf, %u to format unsigned 1 byte value, 0 to put null terminator at the end of string

section .text
main:
        LEA rsi, [list] ; pointer to base of array
        MOV dl, 1 ; make sure dl doesn't start with 0, because 0 = no swap happened, that will exit the program

.outer_loop:
        CMP dl, 0 ; if there was no swap in a inner loop, the array is already sorted, so we can print it
        JE .print
        XOR rax, rax ; clear rax register to count iteration, we need to use rax because address arithmetic need to be 8 bytes in 64 bit program
        XOR dl, dl ; clear the dl register to 0 to keep track of value swap

.inner_loop:
        MOV bl, [rsi + rax] ; move value of the current element in list iteration to bl
        MOV cl, [rsi + rax + 1] ; move value of the next element to cl
        CMP bl, cl ; compare the value from the current pos with next pos, if it's greater, go to .swap_values
        JG .swap_values

.next_inner_iteration:
        INC rax ; increment iterator
        CMP rax, list_size - 1 ; check if iterator is at the last element pos
        JNE .inner_loop ; if not, go to inner loop and compare with the next value, else go to outer loop because there is no next value
        JMP .outer_loop

.swap_values:
        MOV [rsi + rax + 1], bl ; move the current value to next address
        MOV [rsi + rax], cl ; move the next value to current address
        MOV dl, 1 ; if there was a swap in a inner iteration set to 1, to keep track if the array is already sorted (0)
        JMP .next_inner_iteration

.print:
        XOR rbx, rbx ; clear rbx to iterate, we can't use rax to iterate because the return of function call is saved there
.print_loop:
        SUB rsp, 40 ; reserve 32 bytes in stack memory before calling functions (shadow space) + 8 byte for alignment
        ; arguments to printf function (rcx, rdx):
        LEA rcx, [element_string] ; 1 - Pointer to string
        MOVZX rdx, byte [rsi + rbx] ; 2 - The argument to printf (%u), which is the current value in iteration, movzx to move only 1 byte to rdx (8 bytes) setting the rest to 0
        CALL printf
        ADD rsp, 40 ; clean the reserved stack memory
        INC rbx ; increment iterator
        CMP rbx, list_size ; if the iterator is after the last element continue the program (to exit)
        JNE .print_loop ; if the iterator is not after last element continue printing loop

.exit:
        SUB rsp, 40 ; shadow space + memory alignment
        XOR ecx, ecx ; clear ecx, so the exit code is 0
        CALL ExitProcess
