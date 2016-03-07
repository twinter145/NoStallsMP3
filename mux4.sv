//creates 4 input mux, sets up output
module mux4 #(parameter width = 16)
(
input [1:0] sel,
input [width-1:0] a, b, c, d,
output logic [width-1:0] f
);

//internal workings of mux
always_comb
case(sel)
	0: f = a;
	1: f = b;
	2: f = c;
	3: f = d;
endcase
endmodule : mux4