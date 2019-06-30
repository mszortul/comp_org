module shift(shin,shout);
output [31:0] shout;
input [31:0] shin;
assign shout=shin<<2;
endmodule