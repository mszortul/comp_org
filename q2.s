#   QUESTION 2
#       Applies prim's algorithm to a graph thats defined with its arcs as string.
#           Example arc: "node1_id node2_id arc_weight"
#
#   Good
#       It support ids and weights that can be representable with up to 9 characters
#
#   Bad
#       Memory allocation is not dynamic, even the simplest graphs will use the same space as complex ones
#       Maximum number of nodes is limited
#
#
#   Info
#       50 nodes max
#
#       Node
#           10b for id
#           4b for arc_arr length
#           392b for arcs(49 arcs max per node)
#       Arc
#           4b for address it points to
#           4b for weight
#

        .data
buf:    .space 20000                    # buffer that will store the input string

comp:   .space 10                       # buffer for string comparison
visit:  .byte 0:64                      # which nodes are visited, 0 initialized
search: .word -1:64                     # search for small weight in this array of indexes, -1 initialized

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
        add $t8, $zero, $zero           # node1 address
        add $t9, $zero, $zero           # node2 address


        li $v0, 8                       # select read_string mode
        li $a1, 20000                   # max string length to be read is 20000
        la $a0, buf                     # save read input into buf
        syscall                         # execute read_string

        la $s4, buf                     # s4 = &buf
        la $s5, comp                    # s5 = &comp
        add $s6, $zero,$zero            # mode = 0, possible values are (0, 1, 2)


parse:
        add $t0, $s4, $s1               # t0 = &buf[i]
        addi $s1, $s1, 1                # i++, this incremented before the branch, because in the next iteration we want to start from the character that comes after space
        add $t1, $s5, $s2               # t1 = &comp[j]
        lb $t0, 0($t0)                  # t0 = buf[i-1]
        addi $t2, $zero, 32             # decimal value of space in ascii encoding, t2 = 32
        addi $t3, $zero, 10             # decimal value of newline in ascii encoding, t2 = 10
        beq $t0, $t3, prim              # branch if we reached the end of input string and apply prim's algorithm
        beq $t0, $t2, proc_init         # branch if encountered with space
        sb $t0, 0($t1)                  # comp[j] = buf[i-1]
        addi $s2, $s2, 1                # j++
        j parse

proc_init:
        sb $zero, 0($t1)                # add null byte to the end of string in comp
        addi $t2, $zero, 2              # t2 = 2
        beq $s6, $t2, str2int           # if (mode == 2) branch, if not this means mode is 0 or 1 and we are currently reading first or second node id
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
        add $s3, $s3, 1                 # k++, char mismatch occurred between node ids, continue comparing from next node
        add $s2, $zero, $zero           # j = 0
        j proc

str2int:
        # should be t0 = weight at the end
        # s2 is index that shows null byte end of comp string rn

        add $t0, $zero, $zero           # t0 = 0
        addi $t1, $zero, 1              # t1 = 1, multiplier
        addi $t3, $zero, -1             # t3 = -1, needed to check if we pass the head of string
        addi $t4, $zero, 10             # t4 = 10

str2int_loop:
        beq $s2, $t3, save              # if all chars read, integer value of weight should be at $t0, jump and add arcs to nodes
        addi $s2, $s2, -1               # j--
        add $t2, $s5, $s2               # t2 = &comp[j]
        lb $t2, 0($t2)                  # t2 = comp[j]
        mul $t2, $t2, $t1               # t2 = comp[j] * multiplier
        add $t0, $t0, $t2               # t0 = t0 + t2
        mul $t1, $t1, $t4               # multiplier = multiplier * 10
        j str2int_loop

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
        beq $s2, $t3, save              # exit loop(write_new_id) if 10 chars written to id section of new node
        j write_new_id

id_match:
        # ids are matched save node address to $t0

        addi $t0, $zero, 406            # t0 = 406
        mul $t0, $t0, $s3               # t0 = k*406
        add $t0, $t0, $sp               # t0 = k*406 + sp



save:
        add $s2, $zero, $zero           # j = 0, it needs to be 0 in the next iteration
        add $s3, $zero, $zero           # k = 0, next time we search for an id, we should start from beginning of node_arr
        beq $s6, $zero, save0           # if (mode == 0), save node_arr index as first node, store in $t8
        addi $t2, $zero, 1              # t2 = 1
        beq $s6, $t2, save1             # if (mode == 1), save node_arr index as second node, store  in $t9
        addi $t2, $t2, 1                # t2 = 2
        beq $s6, $t2, save2             # if (mode == 2), add arc to nodes, arc weight stored in $t7


save0:                                  # save first node address
        add $t8, $t0, $zero             # t8 = first node address
        addi $s6, $s6, 1                # mode++
        j parse

save1:                                  # save second node address
        add $t9, $t0, $zero             # t9 = second node address
        addi $s6, $s6, 1                # mode++
        j parse

save2:                                  # add arcs
        # t0 = weight
        # t8 = &first_node
        # t9 = &second_node

        addi $t1, $zero, 10             # t1 = 10, space of node_id string
        addi $t3, $zero, 8              # t3 = 8, space of an element of arc_arr
        addi $t4, $zero, 4              # t4 = 4, space of arc_arr_length
        add $t1, $t1, $t8               # address of arc_arr_length of first node
        lw $t2, 0($t1)                  # load arc_arr_length
        mul $t5, $t3, $t2               # t5 = 8*arc_arr_length
        add $t6, $t5, $t1               # t6 = 8*arc_arr_length + 10
        add $t6, $t6, $t4               # t6 = 8*arc_arr_length + 10 + 4, this is where we add new arc data (weight, &second_node)
        sw $t0, 0($t6)                  # weight saved
        sw $t9, 4($t6)                  # &second_node saved
        addi $t2, $t2, 1                # arc_arr_length++
        sw $t2, 0($t1)                  # update old arc_arr_length value
                                        # arc data added to first node


        add $t1, $t1, $t9               # address of arc_arr_length of second node
        lw $t2, 0($t1)                  # load arc_arr_length
        mul $t5, $t3, $t2               # t5 = 8*arc_arr_length
        add $t6, $t5, $t1               # t6 = 8*arc_arr_length + 10
        add $t6, $t6, $t4               # t6 = 8*arc_arr_length + 10 + 4, this is where we add new arc data (weight, &first_node)
        sw $t0, 0($t6)                  # weight saved
        sw $t9, 4($t6)                  # &second_node saved
        addi $t2, $t2, 1                # arc_arr_length++
        sw $t2, 0($t1)                  # update old arc_arr_length value
                                        # arc data added to second node

        add $s6, $zero, $zero           # mode = 0
        j parse


prim:
        # s0 = length of node_arr
        # visit = flag array, once a node visited its flag will be set
        # we will search for the smallest weighted arc over ALL visited nodes

        # let's assume we magically generated a random number between 0 to s0 and stored at $a0, mips might not support it at all(syscall 30, 41, 42 unknown error)

        addi $s0, $s0, -1               # s0 was pointing end of the array, by subtracting 1, we make equation on the right valid (&last_node = sp + 406*s0)
        la $s5, search                  # we no longer need address of comp, s5 = &search

        add $t0, $a0, $zero             # q is a random number, t0 = q
        la $s7, visit                   # s7 = &visit
        add $t0, $s7, $t0               # t0 = &visit + q
        addi $t1, $zero, 1              # t1 = 1
        sb $t1, 0($t0)                  # visit[q] = 1


        add $s2, $zero, $zero           # j = 0
        add $s3, $zero, $zero           # k = 0
        addi $t3, $zero, 60             # t3 = 60, parse till j hits 60

parse_visit:
        add $t0, $s7, $s2               # t0 = &visit[j]
        lb $t0, 0($t0)                  # t0 = visit[j]
        addi $t1, $zero, 1              # t1 = 1

        beq $s2, $t3, begin_search      # if (j == 60) begin searching for the smallest weight
        beq $t0, $t1, add_to_search     # if (visit[j] == 1) we add it's index(j) to search array

continue_parse:
        addi $s2, $s2, 1                # j++
        j parse_visit


add_to_search:


        #
        #
        #   GOTTA LOOK AT THAT WHOLE PRIM THING!!
        #
        #
















































asd: