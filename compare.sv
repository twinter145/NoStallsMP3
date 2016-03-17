module compare #(parameter width = 9)
(
	input [width-1:0] a, b,

	output logic f
);

assign f = a == b;

endmodule : compare