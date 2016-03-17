import lc3b_types::*;

module I_cache
(
	input clk,
	input lc3b_word address,
	input lc3b_line I_rdata,
	input I_resp,
	input read,
	
	output lc3b_word rdata,
	output lc3b_word I_address,
	output logic I_read,
	output logic resp
);

assign I_address = address;

logic lru_write;
logic lru_data;
logic lru_out;
logic waydatamux_sel;
logic way0_valid_data;
logic way1_valid_data;
logic way0_write;
logic way1_write;
logic hit;

I_cache_datapath instr_datapath
(
	.clk(clk),
	.mem_address(address),
	.pmem_rdata(I_rdata),
	.lru_write(lru_write),
	.lru_data(lru_data),
	.way0_valid_data(way0_valid_data),
	.way1_valid_data(way1_valid_data),
	.way0_write(way0_write),
	.way1_write(way1_write),
	.mem_rdata(rdata),
	.hit(hit),
	.lru_out(lru_out),
	.waydatamux_sel(waydatamux_sel)
);

I_cache_control instr_control
(
	.clk(clk),
	.pmem_resp(I_resp),
	.pmem_read(I_read),
	.mem_resp(resp),
	.mem_read(read),
	.hit(hit),
	.lru_out(lru_out),
	.waydatamux_sel(waydatamux_sel),
	.way0_write(way0_write),
	.way1_write(way1_write),
	.way0_valid_data(way0_valid_data),
	.way1_valid_data(way1_valid_data),
	.lru_data(lru_data),
	.lru_write(lru_write)
);

endmodule : I_cache