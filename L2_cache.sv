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
	output logic L2_resp, L2_miss,
	output lc3b_line L2_rdata,
	input L2_read,
	input L2_write,
	input lc3b_word L2_address,
	input lc3b_line L2_wdata
);

logic [2:0] write_sel;
logic write;
logic lru_write;
logic [6:0] lru_data_in;
lc3b_byte valid_in;
lc3b_byte dirty_in;
lc3b_byte dirty_out;
logic [2:0] waydataselect_alt;
logic waydatacontrol;
logic highaddrmux_sel;
logic data_input_select;
logic hit;
logic [6:0] lru_data_out;
logic [2:0] waydatamux_sel;

assign L2_miss = (L2_read | L2_write) & (~L2_resp);

L2_cache_datapath L2_datapath
(
	.clk(clk),
	.write_sel(write_sel),
	.write(write),
	.lru_write(lru_write),
	.lru_data_in(lru_data_in),
	.valid_in(valid_in),
	.dirty_in(dirty_in),
	.waydataselect_alt(waydataselect_alt),
	.waydatacontrol(waydatacontrol),
	.highaddrmux_sel(highaddrmux_sel),
	.data_input_select(data_input_select),
	.pmem_wdata(pmem_wdata),
	.pmem_address(pmem_address),
	.L2_rdata(L2_rdata),
	.hit(hit),
	.lru_data_out(lru_data_out),
	.waydatamux_sel(waydatamux_sel),
	.dirty_out(dirty_out),
	.pmem_rdata(pmem_rdata),
	.L2_address(L2_address),
	.L2_wdata(L2_wdata)
);

L2_cache_control L2_control
(
	.clk(clk),
	.pmem_resp(pmem_resp),
	.pmem_read(pmem_read),
	.pmem_write(pmem_write),
	.L2_resp(L2_resp),
	.L2_read(L2_read),
	.L2_write(L2_write),
	.write_sel(write_sel),
	.write(write),
	.lru_write(lru_write),
	.lru_data_in(lru_data_in),
	.valid_in(valid_in),
	.dirty_in(dirty_in),
	.waydataselect_alt(waydataselect_alt),
	.waydatacontrol(waydatacontrol),
	.highaddrmux_sel(highaddrmux_sel),
	.data_input_select(data_input_select),
	.hit(hit),
	.lru_data_out(lru_data_out),
	.waydatamux_sel(waydatamux_sel),
	.dirty_out(dirty_out)
);

endmodule : L2_cache