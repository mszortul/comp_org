#
#   input :
#           ab
#
#   output:
#           ab
#           97
#           98
#           10
#           0
#           0
#
#   result:
#           stores new line character that we used to send input too.
#

        .data

nextl:  .asciiz "\n"
comp:   .space 10                       # buffer for string comparison

        .text
        .globl main
main:


        li $v0, 8
        li $a1, 6
        la $a0, comp
        syscall


        li $v0, 4
        syscall


        add $t0, $zero, $zero
        addi $t4, $zero, 5

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
