#   50 nodes max
#
#   Node
#       49 arcs max per node
#       10b for id
#       4b for arc_arr length
#       392b for arcs
#   Arc
#       4b for address it points to
#       4b for weight
#

        .data
buf:    .space 20000                    # buffer that will store the input string

comp:   .space 10                       # buffer for string comparison

        .text
        .globl main
main:
        addi $sp, $sp, -52              # reserve space for registers about to be saved
        sw $s0, 0($sp)
        sw $s1, 4($sp)
        sw $s2, 8($sp)
        sw $s3, 12($sp)
        sw $s4, 16($sp)
        sw $s5, 20($sp)
        sw $s6, 24($sp)
        sw $s7, 28($sp)
        sw $a0, 32($sp)
        sw $a1, 36($sp)
        sw $a2, 40($sp)
        sw $a3, 44($sp)
        sw $ra, 48($sp)                 # register values from former procedure is pushed onto stack

        addi $sp, $sp, 20300            # total memory reserved for node array, (49*8+10+4) * 50

        add $s0, $zero, $zero           # l = 0, s0 is where we keep the current length of node array
        add $s1, $zero, $zero           # i = 0
        add $s2, $zero, $zero           # j = 0
        add $s3, $zero, $zero           # k = 0
        add $t8, $zero, $zero           # node1 index
        add $t9, $zero, $zero           # node2 index


        li $v0, 8                       # select read_string mode
        li $a1, 20000                   # max string length to be read is 20000
        la $a0, buf                     # save read input into buf
        syscall                         # execute read_string

        la $s4, buf                     # s4 = &buf
        la $s5, comp                    # s5 = &comp
        add $s6, $zero,$zero            # mode = 0, possible values are (0, 1, 2)

parse:
        add $t0, $s4, $s1               # t0 = &buf[i]
        add $t1, $s5, $s2               # t1 = &comp[j]
        lb $t0, 0($t0)                  # t0 = buf[i]
        addi $t2, $zero, 32             # decimal value of space in ascii encoding, t2 = 32
        beq $t0, $t2, proc_init         # branch if encountered with space
        sb $t0, 0($t1)                  # comp[j] = buf[i]
        addi $s1, $s1, 1                # i++
        addi $s2, $s2, 1                # j++
        j parse

proc_init:
        sb $zero, 0($t1)                # add null byte to the end of string in comp
        add $s2, $zero, $zero           # j = 0
        add $s3, $zero, $zero           # k = 0

proc:                                   # processing cached piece of string before reading the next one
        beq $s3, $s0, add_new_node      # are we at the end of node array, if we are, exit loop(proc) and add new node
        addi $t1, $zero, 406            # space used by an element of node array, n = 406
        mul $t1, $t1, $s3               # distance between current node and sp, t1 = k*n
        add $t1, $sp, $t1               # address of current node, t1 = sp + k*n, t1 = &node_arr[k]

        add $t2, $t1, $s2               # t2 = address of j'th byte from &node_arr[k]
        add $t3, $s5, $s2               # t3 = address of j'th byte of comp
        lb $t2, 0($t2)                  # t2 = j'th byte from &node_arr[k]
        lb $t3, 0($t3)                  # t3 = j'th byte of comp

        or $t4, $t2, $t3                # t4 can be 0 iff both bytes are 0, if t4 is 0, this means that we are at the end of both ids and there hasn't been any char mismatch
        beq $t4, $zero, id_match        # jump to id_match if (t4 == 0), this branch is one of the two possible exits from this loop(proc)

        addi $s2, $s2, 1                # j++

        # if (chr1 == chr2)
        beq $t2, $t3, proc              # chars are same, jump back to proc to continue comparing chars
        # else
        add $s3, $s3, 1                 # k++, char mismatch occured between node ids, continue comparing from next node
        add $s2, $zero, $zero           # j = 0
        j proc

add_new_node:
                                        # j is 0 right now!
        addi $t0, $zero, 406            # n = 406
        mul $t0, $t0, $s0               # t0 = n*l
        add $t0, $t0, $sp               # t0 = sp + n*l, end of the node_arr, this is where we add the next node
        addi $s0, $s0, 1                # l++, add 1 to length of node_arr
        addi $t3, $zero, 10             # constant 10 needed for exit control of loop(write_new_id)
        sw $zero, 10($t0)               # initialize arc_arr length with 0

write_new_id:
        add $t1, $s5, $s2               # t1 = address of j'th element of comp
        lb $t1, 0($t1)                  # t1 = j'th element of comp
        add $t2, $t0, $s2               # t2 = address of j'th byte from start of new node
        sb $t1, 0($t2)                  # byte stored in id section of new node
        addi $s2, $s2, 1                # j++
        beq $s2, $t3, write_id_done     # exit loop(write_new_id) if 10 chars written to id section of new node
        j write_new_id


write_id_done:
        add $s2, $zero, $zero           # j = 0, at this point I don't even know why I'm doing this. RIP brain
        add $s3, $zero, $zero           # k = 0, next time we search for an id, we should start from beginning of node_arr




        # where to jump now? we just wrote the new node id and j is 0.
        #


        # CURRENT STATE:
        #
        #       new node's id copied to memory
        #       only node id comparison part is done
        #       TODO: need to write the length of arc array of a single node to right after the node id part. also, don't forget to initialize with 0.
        #       TODO: reserve external space for index value of nodes that will store the new arc information
        #       TODO: brach according to modes(0, 1, 2)
        #       TODO: string to integer
        #

id_match:
        # ids are matched save arc parameters here
        #
        # DO THIS FIRST!! IT WILL RESOLVE THE ARC ARRAY LENGTH ISSUE! ps: look at todo #1 below current state header :)

        # save k for later access, when adding arc objects

        # TODO: modlara göre farklı kollara gitmeli program mantık hataları var düzenle.

mode0:
        addi $t2, $zero, 1              # t2 = 1
        beq $s6, $t2, mode1             # if (mode == 1) branch
        addi $t2, $t2, 1                # else t2 = 2
        beq $s6, $t2, mode1             # if (mode == 2) branch
                                        # we can now assume that mode is 0, it's the only option left
        j proc_init


mode1:
        add $t8, $zero, $s3


mode2:
        add $t9, $zero, $s3



































































asd:
