import lc3b_types::*;

module L2_cache
(
	input clk,
	
	/* Physical Memory Signals */
	input lc3b_d_line pmem_rdata,
	input pmem_resp,
	output logic pmem_read,
	output logic pmem_write,
	output lc3b_d_line pmem_wdata,
	output lc3b_word pmem_address,
	
	/* Signals to arbiter */
	output logic L2_resp,
	output lc3b_line L2_rdata,
	input L2_read,
	input L2_write,
	input lc3b_word L2_address,
	input lc3b_line L2_wdata
);

L2_cache_datapath L2_datapath
(
	.clk(clk)
);

L2_cache_control L2_control
(
	.clk(clk)
);

endmodule : L2_cache