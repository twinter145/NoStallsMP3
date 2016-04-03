import lc3b_types::*;

module ldb
(
	input clk,
	input lc3b_word address, data_in,
	output lc3b_word data_out
);
lc3b_word data;
always_comb //0 writes low, and 1 writes high
begin
	data = 4'h0;
	if(address[0] == 0)
		data[7:0] = data_in[7:0];
	else	
		data[7:0] = data_in[15:8];
end
assign data_out = data;
endmodule : ldb