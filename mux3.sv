<<<<<<< HEAD
import lc3b_types::*;

module mux3 #(parameter width = 16)
(
	input lc3b_mux_sel sel,
	input [width-1:0] a, b, c,
	output logic [width-1:0] f
);
always_comb
begin
	if (sel == 2'b00)
		f = a;
	else if (sel == 2'b01)
		f = b;
	else if (sel == 2'b10)
		f = c;
	else	
		f = c;
end
=======
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
>>>>>>> 903bc3f056857b84ea56221fa777eac06e01fe7f
endmodule : mux3