import lc3b_types::*;

//creates 4 input mux, sets up output
module mux3 #(parameter width = 16)
(
input [1:0] sel,
input [width-1:0] a, b, c,
output logic [width-1:0] f
);

//internal workings of mux
always_comb
case(sel)
	0: f = a;
	1: f = b;
	2: f = c;
	3: f = 0;
endcase

endmodule : mux3