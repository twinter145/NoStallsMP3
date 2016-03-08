import lc3b_types::*;

module datapath
(
	input clk,
	
	/* memory signals */
	//inputs
	input mem_resp,
	input lc3b_word mem_rdata,
	//outputs
	output mem_read,
	output mem_write,
	output lc3b_mem_wmask mem_byte_enable,
	output lc3b_word mem_address,
	output lc3b_word mem_wdata
	
	/* other stuff */
	//inputs
	
	//outputs
);
//internal signals
lc3b_word wb_mux_out;

//fetch


//decode



//execute


//memory
mem_register mem_register 
(
	.clk
	.load
);

memory memory
(
);

//write back
wb_register wb_regsiter
(
	.clk,
	.load,
);

mux4 wb_mux
(
	.sel(wb_mux_sel),
	.a(wb_address_out),
	.b(wb_rdata_out),
	.c(wb_next_instr_out),
	.d(wb_alu_out),
	.f(wb_mux_out)
);

gencc gencc
(
	.in(wb_mux_out),
	.out(gencc_out)
);

endmodule : datapath
