//creates 8 input mux, sets up output
module mux8 #(parameter width = 16)
(
input [2:0] sel,
input [width-1:0] a, b, c, d, e, g, h, i,
output logic [width-1:0] f
);

//internal workings of mux
always_comb
case(sel)
	0: f = a;
	1: f = b;
	2: f = c;
	3: f = d;
	4: f = e;
	5: f = g;
	6: f = h;
	7: f = i;
endcase
endmodule : mux8