module concat(pc, target, out);
input [31:0] pc, target;
output [31:0] out;

assign out = {pc[31:28], target[27:0]};

endmodule