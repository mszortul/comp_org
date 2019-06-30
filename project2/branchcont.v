module branchcont(updated_pc_reg, aluout, pc4, reg1, memout, pcimm, direct, zero_branch, branch_cont0, branch_cont1, branch_cont2);
input [31:0] aluout, pc4, reg1, memout, pcimm, direct;
input branch_cont0, branch_cont1, branch_cont2, zero_branch;
output [31:0] updated_pc_reg;
reg [31:0] updated_pc_reg;
wire [2:0] signal;
wire n, z;

assign n = aluout[31];
assign z = ~(|aluout);
assign signal = {branch_cont0, branch_cont1, branch_cont2};


always @ (*)
begin


case(signal)
	
	
	3'b000: 
			begin 
			updated_pc_reg = pc4;							// no branch
			end
	3'b001: begin
			updated_pc_reg = z ? reg1 : pc4;				// brz (0/20) branch to register if Z
			if (z) $display("BRANCH TAKEN: register read 1");
			$display("Z: %b",z);
			end
	3'b010: begin
			updated_pc_reg = n ? memout : pc4;				// bmn (21) branch to memory if N
			$display("N: %b",n);
			if (n) $display("BRANCH TAKEN: memory read");
			end
	3'b011: begin
			updated_pc_reg = memout;						// jmor (0/33), jm (18), unconditional jump to memory
			$display("BRANCH TAKEN: memory read");
			end
	3'b100: begin
			updated_pc_reg = z ? direct : pc4;				// bz (24) branch to direct address if Z
			$display("Z: %b",z);
			if (z) $display("BRANCH TAKEN: direct address");
			end
	3'b101: 
			begin
			updated_pc_reg = zero_branch ? pcimm : pc4;		// beq (4) branch if condition true
			if (zero_branch) $display("BRANCH TAKEN: PC + IMM<<2");
			end
	default: updated_pc_reg = pc4;
endcase

end

endmodule