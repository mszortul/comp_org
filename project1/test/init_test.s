#
#
#   it initializes with written value, byte and word both works
#   machine is little endian btw
#
#

        .data

comp:   .byte -1:64
nextl:  .asciiz "\n"


        .text
        .globl main
main:
        add $t0, $zero, $zero
        addi $t4, $zero, 32

loop:
        beq $t0, $t4, exit
        la $a0, comp
        add $t1, $a0, $t0
        lb $a0, 0($t1)
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
