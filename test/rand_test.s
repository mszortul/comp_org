#
#
#   Doesn't recognize 41 and 42 as system calls.
#   System call 30 for system time didn't recognized either.
#

        .data

comp:   .byte 0:64
nextl:  .asciiz "\n"


        .text
        .globl main
main:
        add $t0, $zero, $zero
        addi $t4, $zero, 32

loop:
        beq $t0, $t4, exit
        li $a1, 10              # upper bound is 10
        li $v0, 30              # load random_int
        syscall                 # random int generated and saved to a0

        li $v0, 1
        syscall

        li $v0, 4
        la $a0, nextl
        syscall

        addi $t0, $t0, 1
        j loop

exit:
        li $v0, 10
        syscall
