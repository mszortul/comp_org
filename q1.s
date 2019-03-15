#
# 	WORK IN PROGRESS
#		TODO: There are register related requirements in docs, code needs modification.
#
# QUESTION 1
#   Function
#       According to given parameters, prints elements and sum of an arithmetic series
#
#   Info
#       l = series length
#       t = increment value between consecutive elements (offset)
#       a_n = a_0 + (t * (n-1)) = n'th element of series
#       s = sum of series elements
#
#       s = (a_1 * l) + (((l-1) * l)/2) * t
#

            .data
init_str:   .asciiz "Enter the first number in the series: "
len_str:    .asciiz "Enter the number of integers in the series: "
offset_str: .asciiz "Enter the offset between two successive integers in the series: "

res1:       .asciiz "\nThe series is: "
res2:       .asciiz "\nThe summation of numbers is "

space:      .asciiz " "
nextl:      .asciiz "\n"

            .text
            .globl main
main:
            li $v0, 4
            la $a0, init_str
            syscall                 # print init_str
            li $v0, 5
            syscall                 # get a_1
            move $s0, $v0           # s0 = a_1

            li $v0, 4
            la $a0, len_str
            syscall                 # print len_str
            li $v0, 5
            syscall                 # get length
            move $s1, $v0           # s1 = l

            li $v0, 4
            la $a0, offset_str
            syscall                 # print offset_str
            li $v0, 5
            syscall                 # get offset
            move $s2, $v0           # s2 = t

            mul $t0, $s0, $s1       # t0 = s0 * s1          t0 = a_1 * l
            addi $t1, $s1, -1       # t1 = s1 - 1           t1 = l - 1
            mul $t2, $t1, $s1       # t2 = t1 * s1          t2 = (l-1) * l
            srl $t2, $t2, 1         # t2 = t2/2             t2 = ((l-1) * l) / 2
            mul $t2, $t2, $s2       # t2 = t2 * s2          t2 = (((l-1) * l) / 2) * t
            add $s4, $t0, $t2       # s4 = t0 + t2          s = (a_1 * l) + (((l-1) * l)/2) * t

            li $v0, 4
            la $a0, res1
            syscall                 # print res1

            add $t0, $zero, $zero   # i = 0                 add this to a_1 in every iteration
            mul $s3, $s1, $s2       # s3 = s1 * s2          s3 = l * t

loop:
            beq $t0, $s3, endloop   # break if (a_l - a_1 == l * t)
            li $v0, 1
            add $a0, $s0, $t0       # a_(i/t + 1) = a_1 + i
            syscall                 # print (i/t + 1)th element
            li $v0, 4
            la $a0, space
            syscall                 # print space
            add $t0, $t0, $s2       # increment i by t
            j loop

endloop:
            li $v0, 4
            la $a0, res2
            syscall                 # print res2
            li $v0, 1
            add $a0, $s4, $zero
            syscall                 # print s
            li $v0, 4
            la $a0, nextl
            syscall                 # next line

            li $v0, 10
            syscall                 #exit program
