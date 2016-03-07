import lc3b_types::*;

//creates 2 input module, sets up output
module comparator #(parameter width = 16)
(
	input [width-1:0] a, b,
	output lc3b_nzp f
);

//internal workings of comparator
always_comb
begin
if (a == b)
f = 3'b010;
else if (a > b)
f = 3'b001;
else
f = 3'b100;
end
endmodule : comparator