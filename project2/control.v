module control(in, funct,regdest,alusrc,memtoreg,regwrite,memread,memwrite,
branch_cont0,branch_cont1,branch_cont2,aluop0,aluop1,aluop2,link,shift);
input [5:0] in, funct;
output regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch_cont0,branch_cont1,branch_cont2;
output aluop0, aluop1, aluop2, link, shift;

wire regdest,alusrc,memtoreg,regwrite,memread,memwrite,aluop0,aluop1,aluop2,branch_cont0,branch_cont1,branch_cont2,link,shift;
wire lw,sw,beq,bmn,bz,jm,srl,brz,jmor,add,sub,andg,slt;

// in a real architecture "memread" would be beneficial to resolve complications between writing and reading memory locations
// since this is a simulation, we can write and read as we desire. And we do that, we read from memory in every cycle regardless of what this signal is.
// so we don't actually need this signal, but it was there and we didn't remove it. meh :/


// 100011 lw				(35)
// 101011 sw				(43)
// 000100 beq				(4)
// 010101 bmn				(21)
// 011000 bz				(24)
// 010010 jm				(18)

// 000000 000010 srl		(0/2)
// 000000 010010 brz		(0/18)
// 000000 100001 jmor		(0/33)
// 000000 100000 add		(0/32)
// 000000 100010 sub		(0/34)
// 000000 100100 andg		(0/36)
// 000000 100101 org		(0/37)
// 000000 101010 slt		(0/42)



assign lw=in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];
assign sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];
assign beq=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);
assign bmn=~in[5]& in[4]&(~in[3])&in[2]&(~in[1])&(in[0]); // 010101
assign bz=~in[5]& in[4]&in[3]&(~in[2])&(~in[1])&(~in[0]); // 011000
assign jm=~in[5]& in[4]&(~in[3])&(~in[2])&in[1]&(~in[0]); // 010010
assign srl=~in[5]& (~in[4])&(~in[3])&(~in[2])&(~in[1])&(~in[0])&(~funct[5])&(~funct[4])&(~funct[3])&(~funct[2])&(funct[1])&(~funct[0]);
assign brz=~in[5]& (~in[4])&(~in[3])&(~in[2])&(~in[1])&(~in[0])&(~funct[5])&(funct[4])&(~funct[3])&(~funct[2])&(funct[1])&(~funct[0]);
assign jmor=~in[5]& (~in[4])&(~in[3])&(~in[2])&(~in[1])&(~in[0])&(funct[5])&(~funct[4])&(~funct[3])&(~funct[2])&(~funct[1])&(funct[0]);
assign add=(~in[5])& (~in[4])&(~in[3])&(~in[2])&(~in[1])&(~in[0])&(funct[5])&(~funct[4])&(~funct[3])&(~funct[2])&(~funct[1])&(~funct[0]);
assign sub=~in[5]& (~in[4])&(~in[3])&(~in[2])&(~in[1])&(~in[0])&(funct[5])&(~funct[4])&(~funct[3])&(~funct[2])&(funct[1])&(~funct[0]);
assign andg=~in[5]& (~in[4])&(~in[3])&(~in[2])&(~in[1])&(~in[0])&(funct[5])&(~funct[4])&(~funct[3])&(funct[2])&(~funct[1])&(~funct[0]);
assign org=~in[5]& (~in[4])&(~in[3])&(~in[2])&(~in[1])&(~in[0])&(funct[5])&(~funct[4])&(~funct[3])&(funct[2])&(~funct[1])&(funct[0]);
assign slt=~in[5]& (~in[4])&(~in[3])&(~in[2])&(~in[1])&(~in[0])&(funct[5])&(~funct[4])&(funct[3])&(~funct[2])&(funct[1])&(~funct[0]);

assign regdest = srl|add|sub|andg|slt|org;
assign alusrc = lw|sw|bmn|jm;
assign memtoreg = lw;
assign regwrite = lw|jmor|srl|add|sub|andg|slt|org;
assign memread = lw|jm|bmn|jmor;
assign memwrite = sw;
assign link = jmor;
assign shift = srl;

// ALU control unit removed.
// All operations handled by ALU control unit transferred to main control unit.

// 010 add
// 110 sub
// 111 less
// 000 and
// 001 or
// 100 shift right

assign aluop0 = beq|sub|srl|slt;
assign aluop1 = lw|sw|bmn|jm|add|beq|sub|slt;
assign aluop2 = jmor|slt|org;

// 000 pc+4
// 001 address in register / condition Z
// 010 address in memory / condition N
// 011 address in memory / unconditional
// 100 direct jump {PC+4[31:28],I[25:0]<<2} / condition Z
// 101 beq pc+4+(imm<<2) / condition zero

assign branch_cont0 = bz|beq;
assign branch_cont1 = bmn|jmor|jm;
assign branch_cont2 = brz|beq|jmor|jm;

endmodule
