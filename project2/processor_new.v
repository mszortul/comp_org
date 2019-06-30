module proc;

reg [31:0] registerfile[0:31];
reg [7:0] mem[0:127], datmem[0:31]; // instruction memory extended

reg [31:0] 
pc,
prev_aluout;

reg clock;


wire [31:0] instruction;
wire [5:0] opcode, funct;
wire [4:0] rs, rt, rd, shamt;
wire [15:0] imm;
wire [25:0] addr;


wire 
zout,
regdest,
alusrc,
memtoreg,
regwrite,
memread,
memwrite,
link,
rshift,
branch0,
branch1,
branch2,
alu0,
alu1,
alu2;

wire [31:0]
data,
aluout,
aluin1,
aluin2,
pc4,
imm_ext,
imm_ext_shift,
pc_imm,
addr_shift,
target_addr,
shamt_pad,
next_pc,
out_memtoreg,
out_alusrc,
reg1,
reg2,
write_data;

wire [4:0]
out_regdest,
write_register;

integer i, test_no;

assign opcode = instruction[31:26];
assign rs = instruction[25:21];
assign rt = instruction[20:16];
assign rd = instruction[15:11];
assign shamt = instruction[10:6];
assign funct = instruction[5:0];
assign imm = instruction[15:0];

assign reg1 = registerfile[rs];
assign reg2 = registerfile[rt];
assign instruction = {mem[pc[4:0]],mem[pc[4:0]+1],mem[pc[4:0]+2],mem[pc[4:0]+3]};
assign data = {datmem[aluout[4:0]],datmem[aluout[4:0]+1],datmem[aluout[4:0]+2],datmem[aluout[4:0]+3]};


// Calculate PC + 4
adder add_pc4(pc, 32'h4, pc4);

// Calculate PC + 4 + (imm<<2)
signext ext(imm, imm_ext);
shift imm_2(imm_ext, imm_ext_shift);
adder add_pc_imm(pc4, imm_ext_shift, pc_imm);

// Calculate direct jump address
shift addr_2(instruction, addr_shift);
concat j_addr(pc4, addr_shift, target_addr);

// Calculate aluout and zout
alu32 alu(aluout, aluin1, aluin2, zout, alu0, alu1, alu2);

// Zero extend shamt value
zeropad shamt_0(shamt, shamt_pad);

// Main control unit
control main_control(opcode,funct,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch0,branch1,branch2,alu0,alu1,alu2,link,rshift);

// Branch control unit
branchcont branch_control(next_pc, prev_aluout, pc4, reg1, data, pc_imm, target_addr, zout, branch0, branch1, branch2);

// Write register number
mult5 regdest_mux(out_regdest, rt, rd, regdest);
mult5 link_reg_no(write_register, out_regdest, 5'b11111, link);

// Write register data
mult32 memtoreg_mux(out_memtoreg, aluout, data, memtoreg);
mult32 link_reg_data(write_data, out_memtoreg, pc4, link);

// ALU input 1
mult32 shift_mux_1(aluin1, reg1, reg2, rshift);

// ALU input 2
mult32 alusrc_mux(out_alusrc, reg2, imm_ext, alusrc);
mult32 shift_mux_2(aluin2, out_alusrc, shamt_pad, rshift);

initial begin
pc = 32'h0;
clock = 1'b1;


// SELECT TEST CASE HERE
// 1. R-type ALU operations (add,sub,and,or,slt,srl)
// 2. Load/Store word (lw,sw)
// 3. Branch Equal (beq)
// 4. bmn
// 5. brz
// 6. bz
// 7. jm
// 8. jmor
test_no = 8;

case(test_no)
1:	begin
	$readmemh("data/rtype_alu_dm.dat",datmem); //read Data Memory
	$readmemh("data/rtype_alu_im.dat",mem);//read Instruction Memory
	$readmemh("data/rtype_alu_regs.dat",registerfile);//read Register File
	$display("MIPS: add $3, $1, $2		# $1=0xaa		$2=0x11");
	$display("MIPS: sub $6, $4, $5		# $4=0x55		$5=0x22");
	$display("MIPS: and $9, $7, $8		# $7=0xff		$8=0x88");
	$display("MIPS: or $12, $10, $11	# $10=0xa0		$11=0x0b");
	$display("MIPS: slt $15, $13, $14	# $13=0x01		$14=0x10");
	$display("MIPS: srl $17, $16, 0x4	# $16=0xaa00");
	end
2:	begin
	$readmemh("data/lwsw_dm.dat",datmem); //read Data Memory
	$readmemh("data/lwsw_im.dat",mem);//read Instruction Memory
	$readmemh("data/lwsw_regs.dat",registerfile);//read Register File
	$display("MIPS: lw $22, 4($21)		# $21=0x4");
	$display("MIPS: sw $24, 4($23)		# $23=0x8");
	end
3:	begin
	$readmemh("data/beq_dm.dat",datmem); //read Data Memory
	$readmemh("data/beq_im.dat",mem);//read Instruction Memory
	$readmemh("data/beq_regs.dat",registerfile);//read Register File
	$display("MIPS: add $3, $1, $2		# $1=0xaa	$2=0x11");
	$display("MIPS: sub $6, $4, $5		# $4=0x55	$5=0x22");
	$display("MIPS: beq $25, $26, 1		# $25=0xef	$26=0xef		# if R[25] = R[26] jump to PC+4+(1<<2)");
	$display("MIPS: and $9, $7, $8		# $7=0xff	$8=0x88");
	$display("MIPS: or $12, $10, $11	# $10=0xa0	$11=0x0b");
	end
4:	begin
	$readmemh("data/bmn_dm.dat",datmem); //read Data Memory
	$readmemh("data/bmn_im.dat",mem);//read Instruction Memory
	$readmemh("data/bmn_regs.dat",registerfile);//read Register File
	$display("MIPS: add $3, $1, $2		# $1=0xaa	$2=0x11");
	$display("MIPS: sub $6, $4, $5		# $4=0x22	$5=0x23");
	$display("MIPS: bmn 4($27)			# $27=0x4					# if N jump to M[R[27] + 4]");
	$display("MIPS: and $9, $7, $8		# $7=0xff	$8=0x88");
	$display("MIPS: or $12, $10, $11	# $10=0xa0	$11=0x0b");
	end
5:	begin
	$readmemh("data/brz_dm.dat",datmem); //read Data Memory
	$readmemh("data/brz_im.dat",mem);//read Instruction Memory
	$readmemh("data/brz_regs.dat",registerfile);//read Register File
	$display("MIPS: add $3, $1, $2		# $1=0xaa	$2=0x11");
	$display("MIPS: sub $6, $4, $5		# $4=0x22	$5=0x22");
	$display("MIPS: brz $20				# $20=0x14					# if Z jump to R[20]");
	$display("MIPS: and $9, $7, $8		# $7=0xff	$8=0x88");
	$display("MIPS: or $12, $10, $11	# $10=0xa0	$11=0x0b");
	end
6:	begin
	$readmemh("data/bz_dm.dat",datmem); //read Data Memory
	$readmemh("data/bz_im.dat",mem);//read Instruction Memory
	$readmemh("data/bz_regs.dat",registerfile);//read Register File
	$display("MIPS: add $3, $1, $2		# $1=0xaa	$2=0x11");
	$display("MIPS: sub $6, $4, $5		# $4=0x22	$5=0x22");
	$display("MIPS: bz 0x5											# if Z jump to 0x5<<2=0x14");
	$display("MIPS: and $9, $7, $8		# $7=0xff	$8=0x88");
	$display("MIPS: or $12, $10, $11	# $10=0xa0	$11=0x0b");
	end
7:	begin
	$readmemh("data/jm_dm.dat",datmem); //read Data Memory
	$readmemh("data/jm_im.dat",mem);//read Instruction Memory
	$readmemh("data/jm_regs.dat",registerfile);//read Register File
	$display("MIPS: add $3, $1, $2		# $1=0xaa	$2=0x11");
	$display("MIPS: sub $6, $4, $5		# $4=0x22	$5=0x23");
	$display("MIPS: jm 4($28)			# $28=0x4					# jump to M[R[28] + 4]");
	$display("MIPS: and $9, $7, $8		# $7=0xff	$8=0x88");
	$display("MIPS: or $12, $10, $11	# $10=0xa0	$11=0x0b");
	end
8:	begin
	$readmemh("data/jmor_dm.dat",datmem); //read Data Memory
	$readmemh("data/jmor_im.dat",mem);//read Instruction Memory
	$readmemh("data/jmor_regs.dat",registerfile);//read Register File
	$display("MIPS: add $3, $1, $2		# $1=0xaa	$2=0x11");
	$display("MIPS: sub $6, $4, $5		# $4=0x22	$5=0x23");
	$display("MIPS: jmor $18, $19		# $18=0x10	$19=0x8		# jump to M[R[18]|R[19]] and link($31 = PC+4)");
	$display("MIPS: and $9, $7, $8		# $7=0xff	$8=0x88");
	$display("MIPS: or $12, $10, $11	# $10=0xa0	$11=0x0b");
	end
endcase

for(i=0; i<32; i=i+1)
$display("INIT: Instr. Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
"Register[%0d]= %h",i,registerfile[i]);

#400 $finish;

end

initial forever #20 clock = ~clock;

// Modelsim starts the clock from 0.5 regardless of its initial value. (Big oopsie)
// If we initialize clock with 0 simulation starts with "negedge clock" and pc value gets messed up, execution continues with DON'T CARE bits. (literally not working)
// If we initialize clock with 1 simulation starts with "posedge clock".
// Since memory and register write operations are done in "posedge clock", first operation can't write onto registerfile or memory.
// As a solution we initialize clock with 1 and we put a dummy instruction as the first instruction. After one clock cycle instruction execution continues properly.
// Ignore first instruction for all test cases.

always @ (posedge clock)
begin
registerfile[write_register] = regwrite ? write_data : registerfile[write_register];

if (memwrite)
begin
datmem[aluout[4:0]+3]=reg2[7:0];
datmem[aluout[4:0]+2]=reg2[15:8];
datmem[aluout[4:0]+1]=reg2[23:16];
datmem[aluout[4:0]]=reg2[31:24];
end
end

always @ (negedge clock)
begin
$display("UPDATING(negedge): previous ALU register = %h", prev_aluout);
$display("UPDATING(negedge): pc = %h", next_pc, "\n");
prev_aluout = aluout;
pc = next_pc;
end


always @ (posedge clock)
begin
$display("STATE:  ", " PC %h",pc,"  INST %h",instruction[31:0],"  ALUOUT %h",aluout,"  PREV ALUOUT: %h",prev_aluout, $time);

case(test_no)
1:
	for(i=1; i<20; i=i+1)
	$display("R[%0d] = %h",i,registerfile[i]);
2:	begin
		for(i=20; i<28; i=i+1)
		$display("R[%0d] = %h",i,registerfile[i]);
		for(i=0; i<20; i=i+4)
		$display("M[%0d:%0d] = %h%h%h%h", i, i+3, datmem[i],datmem[i+1],datmem[i+2],datmem[i+3]);
	end
3:
	for(i=1; i<16; i=i+1)
	$display("R[%0d] = %h",i,registerfile[i]);
4:
	for(i=1; i<16; i=i+1)
	$display("R[%0d] = %h",i,registerfile[i]);
5:
	for(i=1; i<16; i=i+1)
	$display("R[%0d] = %h",i,registerfile[i]);
6:
	for(i=1; i<16; i=i+1)
	$display("R[%0d] = %h",i,registerfile[i]);
7:	
	for(i=1; i<16; i=i+1)
	$display("R[%0d] = %h",i,registerfile[i]);
8:	begin
		for(i=1; i<16; i=i+1)
		$display("R[%0d] = %h",i,registerfile[i]);
		$display("R[%0d] = %h", 31, registerfile[31]);
	end
endcase

$display("\n\n");

end
endmodule