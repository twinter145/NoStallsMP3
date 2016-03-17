module decoder #(parameter width = 3)
(
	input [width-1:0] in,
	
	output logic [2**width-1:0] out
);

assign out = 1 << in;			

endmodule : decoder