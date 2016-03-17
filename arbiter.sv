import lc3b_types::*;

module arbiter
(
	input clk,
	
	/* Instruction Cache I/O */
	input lc3b_word I_address,
	input I_read,
	output lc3b_line I_rdata,
	output logic I_resp,
	
	/* Data Cache I/O */
	input lc3b_line D_wdata,
	input lc3b_word D_address,
	input D_read,
	input D_write,
	output lc3b_line D_rdata,
	output logic D_resp,
	
	/* L2 Cache I/O */
	input lc3b_line L2_rdata,
	input L2_resp,
	output lc3b_line L2_wdata,
	output lc3b_word L2_address,
	output logic L2_read,
	output logic L2_write
);

logic I_resp_en;
logic D_resp_en;
logic cache_select;

assign I_resp = I_resp_en & L2_resp;
assign D_resp = D_resp_en & L2_resp;
assign L2_wdata = D_wdata;
assign I_rdata = L2_rdata;
assign D_rdata = L2_rdata;

arbiter_control arbiter_controller
(
	.clk(clk),
	.I_read(I_read),
	.D_write(D_write),
	.D_read(D_read),
	.L2_resp(L2_resp),
	.L2_write(L2_write),
	.L2_read(L2_read),
	.I_resp_en(I_resp_en),
	.D_resp_en(D_resp_en),
	.cache_select(cache_select)
);

mux2 ID_addrmux
(
	.sel(cache_select),
	.a(I_address),
	.b(D_address),
	.f(L2_address)
);

endmodule : arbiter
	