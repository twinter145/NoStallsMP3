import lc3b_types::*;

module D_cache
(
	input clk,
	
	/* Physical Memory Signals */
	input lc3b_line pmem_rdata,
	input pmem_resp,
	output logic pmem_read,
	output logic pmem_write,
	output lc3b_line pmem_wdata,
	output lc3b_word pmem_address,
	
	/* CPU Memory Signals */
	output logic mem_resp,
	output lc3b_word mem_rdata,
	input mem_read,
	input mem_write,
	input lc3b_mem_wmask mem_byte_enable,
	input lc3b_word mem_address,
	input lc3b_word mem_wdata
);

logic lru_write;
logic lru_data;
logic lru_out;
logic way0_write;
logic way1_write;
logic hit;
logic data_input_select;
logic way0_dirty_data;
logic way1_dirty_data;
logic way0_valid_data;
logic way1_valid_data;
logic way0_dirty_out;
logic way1_dirty_out;
logic highaddrmux_sel;
logic tagmux_sel;
logic waydatacontrol;
logic waydataselect_alt;
logic waydatamux_sel;

D_cache_datapath lc3cache_datapath
(
	.clk(clk),
	.mem_address(mem_address),
	.mem_wdata(mem_wdata),
	.pmem_rdata(pmem_rdata),
	.mem_byte_enable(mem_byte_enable),
	.lru_write(lru_write),
	.lru_data(lru_data),
	.way0_dirty_data(way0_dirty_data),
	.way1_dirty_data(way1_dirty_data),
	.way0_valid_data(way0_valid_data),
	.way1_valid_data(way1_valid_data),
	.way0_write(way0_write),
	.way1_write(way1_write),
	.data_input_select(data_input_select),
	.highaddrmux_sel(highaddrmux_sel),
	.tagmux_sel(tagmux_sel),
	.waydatacontrol(waydatacontrol),
	.waydataselect_alt(waydataselect_alt),
	.mem_rdata(mem_rdata),
	.pmem_address(pmem_address),
	.pmem_wdata(pmem_wdata),
	.hit(hit),
	.way0_dirty_out(way0_dirty_out),
	.way1_dirty_out(way1_dirty_out),
	.lru_out(lru_out),
	.waydatamux_sel(waydatamux_sel)
);

D_cache_control lc3cache_control
(
	.clk(clk),
	.pmem_resp(pmem_resp),
	.pmem_read(pmem_read),
	.pmem_write(pmem_write),
	.mem_resp(mem_resp),
	.mem_read(mem_read),
	.mem_write(mem_write),
	.mem_byte_enable(mem_byte_enable),
	.hit(hit),
	.lru_out(lru_out),
	.way0_dirty_out(way0_dirty_out),
	.way1_dirty_out(way1_dirty_out),
	.waydatamux_sel(waydatamux_sel),
	.way0_write(way0_write),
	.way1_write(way1_write),
	.way0_dirty_data(way0_dirty_data),
	.way1_dirty_data(way1_dirty_data),
	.way0_valid_data(way0_valid_data),
	.way1_valid_data(way1_valid_data),
	.lru_data(lru_data),
	.lru_write(lru_write),
	.data_input_select(data_input_select),
	.highaddrmux_sel(highaddrmux_sel),
	.tagmux_sel(tagmux_sel),
	.waydatacontrol(waydatacontrol),
	.waydataselect_alt(waydataselect_alt)
);

endmodule : D_cache