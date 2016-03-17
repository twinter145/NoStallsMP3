import lc3b_types::*;

module L2_cache_datapath
(
	input clk,
	
	output lc3b_d_line pmem_wdata,
	
	input lc3b_word L2_address
);

lc3b_c_index index;
assign index = L2_address[4:2];

logic offset;
assign offset = L2_address[1];

lc3b_L2_tag tag;
assign tag = L2_address[15:5];

lc3b_d_line data_array_in;

/* data outputs */
lc3b_d_line data_out0;
lc3b_d_line data_out1;
lc3b_d_line data_out2;
lc3b_d_line data_out3;
lc3b_d_line data_out4;
lc3b_d_line data_out5;
lc3b_d_line data_out6;
lc3b_d_line data_out7;

/* tag outputs */
lc3b_L2_tag tag_out0;
lc3b_L2_tag tag_out1;
lc3b_L2_tag tag_out2;
lc3b_L2_tag tag_out3;
lc3b_L2_tag tag_out4;
lc3b_L2_tag tag_out5;
lc3b_L2_tag tag_out6;
lc3b_L2_tag tag_out7;

/* valid bit outputs */
lc3b_byte valid_bits;

/* dirty bit outputs */
lc3b_byte dirty_bits;

/* Data Arrays */
arrays data_arrays
(
	.clk(clk),
	.write(write),
	.index(index),
	.datain(data_array_in),
	.out0(data_out0),
	.out1(data_out1),
	.out2(data_out2),
	.out3(data_out3),
	.out4(data_out4),
	.out5(data_out5),
	.out6(data_out6),
	.out7(data_out7)
);

mux8 #(.width(256)) waydatamux
(
	.sel(waydatamux_sel),
	.a(data_out0),
	.b(data_out1),
	.c(data_out2),
	.d(data_out3),
	.e(data_out4),
	.g(data_out5),
	.h(data_out6),
	.i(data_out7),
	.f(pmem_wdata)
);

/* Tag Arrays */
arrays #(.width(11)) tag_arrays
(
	.clk(clk),
	.write(write),
	.index(index),
	.datain(tag),
	.out0(tag_out0),
	.out1(tag_out1),
	.out2(tag_out2),
	.out3(tag_out3),
	.out4(tag_out4),
	.out5(tag_out5),
	.out6(tag_out6),
	.out7(tag_out7)
);

/* Valid Bit Arrays */
arrays #(.width(1)) valid_arrays
(
	.clk(clk),
	.write(write),
	.index(index),
	.datain(),
	.out0(valid_bits[0]),
	.out1(valid_bits[1]),
	.out2(valid_bits[2]),
	.out3(valid_bits[3]),
	.out4(valid_bits[4]),
	.out5(valid_bits[5]),
	.out6(valid_bits[6]),
	.out7(valid_bits[7])
);

/* Dirty Bit Arrays */
arrays #(.width(1)) dirty_arrays
(
	.clk(clk),
	.write(write),
	.index(index),
	.datain(),
	.out0(dirty_bits[0]),
	.out1(dirty_bits[1]),
	.out2(dirty_bits[2]),
	.out3(dirty_bits[3]),
	.out4(dirty_bits[4]),
	.out5(dirty_bits[5]),
	.out6(dirty_bits[6]),
	.out7(dirty_bits[7])
);

endmodule : L2_cache_datapath