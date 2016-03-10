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
endmodule : mux3