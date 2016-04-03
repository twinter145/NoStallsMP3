import lc3b_types::*;

module L2_cache_datapath
(
	input clk,
	input [2:0] write_sel,
	input write,
	input lru_write,
	input [6:0] lru_data_in,
	input lc3b_byte valid_in,
	input lc3b_byte dirty_in,
	input [2:0] waydataselect_alt,
	input waydatacontrol,
	input highaddrmux_sel,
	input data_input_select,
	
	output lc3b_d_line pmem_wdata,
	output lc3b_word pmem_address,
	output lc3b_line L2_rdata,
	output logic hit,
	output logic [6:0] lru_data_out,
	output logic [2:0] waydatamux_sel,
	output lc3b_byte dirty_out,
	
	input lc3b_d_line pmem_rdata,
	input lc3b_word L2_address,
	input lc3b_line L2_wdata
);

lc3b_c_index index;
assign index = L2_address[4:2];

logic offset;
assign offset = L2_address[1];

lc3b_L2_tag tag;
assign tag = L2_address[15:5];

lc3b_d_line data_array_in;
lc3b_line inmux_msb_out;
lc3b_line inmux_lsb_out;
lc3b_byte compare_result;

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
lc3b_byte valid_out;

/* Data Arrays */
arrays #(.width(256)) data_arrays
(
	.clk(clk),
	.write(write),
	.write_sel(write_sel),
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

mux2 #(.width(128)) L2_rdatamux
(
	.sel(offset),
	.a(pmem_wdata[127:0]),
	.b(pmem_wdata[255:128]),
	.f(L2_rdata)
);

/* Tag Arrays */
arrays #(.width(11)) tag_arrays
(
	.clk(clk),
	.write(write),
	.write_sel(write_sel),
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
dvarrays #(.width(1)) valid_arrays
(
	.clk(clk),
	.write(write),
	.write_sel(write_sel),
	.index(index),
	.datain(valid_in),
	.out0(valid_out[0]),
	.out1(valid_out[1]),
	.out2(valid_out[2]),
	.out3(valid_out[3]),
	.out4(valid_out[4]),
	.out5(valid_out[5]),
	.out6(valid_out[6]),
	.out7(valid_out[7])
);

/* Dirty Bit Arrays */
dvarrays #(.width(1)) dirty_arrays
(
	.clk(clk),
	.write(write),
	.write_sel(write_sel),
	.index(index),
	.datain(dirty_in),
	.out0(dirty_out[0]),
	.out1(dirty_out[1]),
	.out2(dirty_out[2]),
	.out3(dirty_out[3]),
	.out4(dirty_out[4]),
	.out5(dirty_out[5]),
	.out6(dirty_out[6]),
	.out7(dirty_out[7])
);

/* Pseudo-LRU Array */
array #(.width(7)) pseudo_lru_array
(
	.clk(clk),
	.write(lru_write),
	.index(index),
	.datain(lru_data_in),
	.dataout(lru_data_out)
);

/* hit signal logic */
tag_compare tag_comparators
(
	.tag(tag),
	.in0(tag_out0),
	.in1(tag_out1),
	.in2(tag_out2),
	.in3(tag_out3),
	.in4(tag_out4),
	.in5(tag_out5),
	.in6(tag_out6),
	.in7(tag_out7),
	.result(compare_result)
);

lc3b_byte hit_array;
logic [2:0] encoder_out;

assign hit_array = compare_result & valid_out;
/*
assign hit_array[0] = compare_result[0] & valid_bits[0];
assign hit_array[1] = compare_result[1] & valid_bits[1];
assign hit_array[2] = compare_result[2] & valid_bits[2];
assign hit_array[3] = compare_result[3] & valid_bits[3];
assign hit_array[4] = compare_result[4] & valid_bits[4];
assign hit_array[5] = compare_result[5] & valid_bits[5];
assign hit_array[6] = compare_result[6] & valid_bits[6];
assign hit_array[7] = compare_result[7] & valid_bits[7];
*/

always_comb
begin
	if(hit_array != 0)
		hit = 1;
	else
		hit = 0;
end

encoder hit_encoder
(
	.in(hit_array),
	.out(encoder_out)
);

mux2 #(.width(3)) control_select
(
	.sel(waydatacontrol),
	.a(encoder_out),
	.b(waydataselect_alt),
	.f(waydatamux_sel)
);

/* pmem_address logic */
assign pmem_address[4:0] = L2_address[4:0];
lc3b_L2_tag tagmux_out;

mux8 #(.width(11)) tagmux
(
	.sel(waydatamux_sel),
	.a(tag_out0),
	.b(tag_out1),
	.c(tag_out2),
	.d(tag_out3),
	.e(tag_out4),
	.g(tag_out5),
	.h(tag_out6),
	.i(tag_out7),
	.f(tagmux_out)
);

mux2 #(.width(11)) highaddrmux
(
	.sel(highaddrmux_sel),
	.a(tag),
	.b(tagmux_out),
	.f(pmem_address[15:5])
);

/* Input Data Logic */
mux2 #(.width(128)) inmux_msb
(
	.sel(offset),
	.a(L2_wdata),
	.b(pmem_wdata[255:128]),
	.f(inmux_msb_out)
);

mux2 #(.width(128)) inmux_lsb
(
	.sel(~offset),
	.a(L2_wdata),
	.b(pmem_wdata[127:0]),
	.f(inmux_lsb_out)
);

mux2 #(.width(256)) datain_select
(
	.sel(data_input_select),
	.a({inmux_msb_out, inmux_lsb_out}),
	.b(pmem_rdata),
	.f(data_array_in)
);

endmodule : L2_cache_datapath