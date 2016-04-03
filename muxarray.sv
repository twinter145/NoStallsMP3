import lc3b_types::*;

module muxarray
(
	input lc3b_word line_data,
	input lc3b_word mem_wdata,
	input lc3b_mem_wmask mem_byte_enable,
	input decoder_bit,
	
	output lc3b_word out
);

lc3b_byte highmux_out;
lc3b_byte lowmux_out;

/* 2 8-bit 2-to-1 muxes */
mux2 #(.width(8)) highmux
(
	.sel(mem_byte_enable[1]),
	.a(line_data[15:8]),
	.b(mem_wdata[15:8]),
	.f(highmux_out)
);

mux2 #(.width(8)) lowmux
(
	.sel(mem_byte_enable[0]),
	.a(line_data[7:0]),
	.b(mem_wdata[7:0]),
	.f(lowmux_out)
);

mux2 memselect
(
	.sel(decoder_bit),
	.a(line_data),
	.b({highmux_out, lowmux_out}),
	.f(out)
);

endmodule : muxarray