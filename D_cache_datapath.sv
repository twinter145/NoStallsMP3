import lc3b_types::*;

module D_cache_datapath
(
	input clk,
	
	input lc3b_word mem_address,
	input lc3b_word mem_wdata,
	input lc3b_line pmem_rdata,
	input lc3b_mem_wmask mem_byte_enable,
	
	input lru_write,
	input lru_data,
	input way0_dirty_data,
	input way1_dirty_data,
	input way0_valid_data,
	input way1_valid_data,
	input way0_write,
	input way1_write,
	input data_input_select,
	input highaddrmux_sel,
	input tagmux_sel,
	input waydatacontrol,
	input waydataselect_alt,
	
	output lc3b_word mem_rdata,
	output lc3b_word pmem_address,
	output lc3b_line pmem_wdata,
	
	output logic hit,
	output logic way0_dirty_out,
	output logic way1_dirty_out,
	output logic lru_out,
	output logic waydatamux_sel
);

lc3b_c_offset offset;
lc3b_c_index index;
lc3b_line way0_data_out;
lc3b_line way1_data_out;
lc3b_c_tag way0_tag_out;
lc3b_c_tag way1_tag_out;
//lc3b_c_tag tag_sel_out;
lc3b_c_tag tagmux_out;
lc3b_line way0_mem_line;
lc3b_line way1_mem_line;
lc3b_line way0_data_input;
lc3b_line way1_data_input;
lc3b_byte decoder_out;
logic way0_valid_out;
logic way1_valid_out;
logic way0_comp_out;
logic way1_comp_out;
logic way0_v_and_comp;
logic way1_v_and_comp;
logic waydatamuxhit_sel;

assign pmem_address[6:0] = mem_address[6:0];
assign offset = mem_address[3:1];
assign index = mem_address[6:4];

/* Data Arrays */
array way0data
(
	.clk(clk),
	.write(way0_write),
	.index(index),
	.datain(way0_data_input),
	.dataout(way0_data_out)
);

array way1data
(
	.clk(clk),
	.write(way1_write),
	.index(index),
	.datain(way1_data_input),
	.dataout(way1_data_out)
);

/* Tag Arrays */
array #(.width(9)) way0tags
(
	.clk(clk),
	.write(way0_write),
	.index(index),
	.datain(mem_address[15:7]),
	.dataout(way0_tag_out)
);

array #(.width(9)) way1tags
(
	.clk(clk),
	.write(way1_write),
	.index(index),
	.datain(mem_address[15:7]),
	.dataout(way1_tag_out)
);

/* Valid Bit Arrays */
array #(.width(1)) way0validbit
(
	.clk(clk),
	.write(way0_write),
	.index(index),
	.datain(way0_valid_data),
	.dataout(way0_valid_out)
);

array #(.width(1)) way1validbit
(
	.clk(clk),
	.write(way1_write),
	.index(index),
	.datain(way1_valid_data),
	.dataout(way1_valid_out)
);

/* Dirty Bit Arrays */
array #(.width(1)) way0dirtybit
(
	.clk(clk),
	.write(way0_write),
	.index(index),
	.datain(way0_dirty_data),
	.dataout(way0_dirty_out)
);

array #(.width(1)) way1dirtybit
(
	.clk(clk),
	.write(way1_write),
	.index(index),
	.datain(way1_dirty_data),
	.dataout(way1_dirty_out)
);

/* LRU Bit Array */
array #(.width(1)) lruarray
(
	.clk(clk),
	.write(lru_write),
	.index(index),
	.datain(lru_data),
	.dataout(lru_out)
);

/* Array output logic */
mux2 #(.width(128)) waydatamux
(
	.sel(waydatamux_sel),
	.a(way0_data_out),
	.b(way1_data_out),
	.f(pmem_wdata)
);

mux2 #(.width(1)) control_selector
(
	.sel(waydatacontrol),
	.a(waydatamuxhit_sel),
	.b(waydataselect_alt),
	.f(waydatamux_sel)
);

mux8 memrdatamux
(
	.sel(offset),
	.a(pmem_wdata[15:0]),
	.b(pmem_wdata[31:16]),
	.c(pmem_wdata[47:32]),
	.d(pmem_wdata[63:48]),
	.e(pmem_wdata[79:64]),
	.g(pmem_wdata[95:80]),
	.h(pmem_wdata[111:96]),
	.i(pmem_wdata[127:112]),
	.f(mem_rdata)
);

compare way0comp
(
	.a(mem_address[15:7]),
	.b(way0_tag_out),
	.f(way0_comp_out)
);

compare way1comp
(
	.a(mem_address[15:7]),
	.b(way1_tag_out),
	.f(way1_comp_out)
);

always_comb
begin
	way0_v_and_comp = way0_comp_out & way0_valid_out;
	way1_v_and_comp = way1_comp_out & way1_valid_out;
	hit = way0_v_and_comp | way1_v_and_comp;

	waydatamuxhit_sel = (~way0_v_and_comp) & way1_v_and_comp;
end

/* Array input logic */
datainlogic way0inputlogic
(
	.offset(offset),
	.mem_wdata(mem_wdata),
	.array_data(way0_data_out),
	.mem_byte_enable(mem_byte_enable),
	.mem_line(way0_mem_line)
);

datainlogic way1inputlogic
(
	.offset(offset),
	.mem_wdata(mem_wdata),
	.array_data(way1_data_out),
	.mem_byte_enable(mem_byte_enable),
	.mem_line(way1_mem_line)
);

mux2 #(.width(128)) way0select
(
	.sel(data_input_select),
	.a(way0_mem_line),
	.b(pmem_rdata),
	.f(way0_data_input)
);

mux2 #(.width(128)) way1select
(
	.sel(data_input_select),
	.a(way1_mem_line),
	.b(pmem_rdata),
	.f(way1_data_input)
);

/* pmem_address logic */
mux2 #(.width(9)) tagmux
(
	.sel(tagmux_sel),
	.a(way0_tag_out),
	.b(way1_tag_out),
	.f(tagmux_out)
);

mux2 #(.width(9)) highaddrmux
(
	.sel(highaddrmux_sel),
	.a(mem_address[15:7]),
	.b(tagmux_out),
	.f(pmem_address[15:7])
);

endmodule : D_cache_datapath