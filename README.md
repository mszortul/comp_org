## Computer Organization Spring 2019


### Project 1

MIPS implementation of:
1. Sum of an arithmetic series  
2. Caesar cipher                
3. Prim's algorithm             

### Project 2

Processor implementation in verilog that supports some basic MIPS instructions and following custom instructions.

#### basic:

- add, sub, and, or, slt, lw, sw, beq

#### custom:

- bmn I-type opcode=21 bmn imm16($rs) if Status [N] = 1, branches to address found in memory

- brz R-type funct=20 brz $rs if Status [Z] = 1, branches to address found in register $rs.

- jmor R-type funct=33 jmor $rs,$rt jumps to address found in memory [$rs|$rt], link address is stored in $31

- bz J-type opcode=24 bz Target if Status [Z] = 1, branches to pseudo-direct address (formed as j does)

- jm I-type opcode=18 jm imm16($rs) jumps to address found in memory (indirect jump)

- srl R-type func=2 srl $rd, $rt, shamt shift register $rt to right by shift amount (shamt) and store the result in register $rd.

---

simulate "proc" module which is defined inside processor_new.v

select test case by changing the "test_no" variable (1 to 8) at processor_new.v(120-129)

simulation lengths for each test case below are enough to analyze the execution:

- 240ns (test1)
- 80ns  (test2)
- 160ns (test3-8)

ignore first instruction for all test cases(explanation at processor_new.v(222-227))
