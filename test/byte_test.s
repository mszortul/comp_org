# Test to see if input stream can be read by multiple instructions. (byte by byte)

        .data
buf:    .space 10

        .text
        .globl main

main:
        li $v0, 8
        li $a1, 2
        la $a0, buf
        syscall         #read byte
        addi $a0, $a0, 1
        syscall
        addi $a0, $a0, 1
        syscall
        addi $a0, $a0, 1
        syscall
        addi $a0, $a0, 1
        syscall
        addi $a0, $a0, 1
        syscall
        addi $a0, $a0, 1
        syscall

        sb $zero, 1($a0)

        li $v0, 4
        addi $a0, $a0, -6
        syscall

        li $v0, 10
        syscall

#
# Yields an error at the end: Unknown spim command
# Find out why.
#
