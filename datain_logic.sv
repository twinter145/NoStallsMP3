import lc3b_types::*;

module datainlogic
(
	input lc3b_c_offset offset,
	input lc3b_word mem_wdata,
	input lc3b_line array_data,
	input lc3b_mem_wmask mem_byte_enable,
	
	output lc3b_line mem_line
);

lc3b_byte decoder_out;

decoder offsetdecoder
(
	.in(offset),
	.out(decoder_out)
);

muxarray muxarray0
(
	.line_data(array_data[127:112]),
	.mem_wdata(mem_wdata),
	.mem_byte_enable(mem_byte_enable),
	.decoder_bit(decoder_out[7]),
	.out(mem_line[127:112])
);

muxarray muxarray1
(
	.line_data(array_data[111:96]),
	.mem_wdata(mem_wdata),
	.mem_byte_enable(mem_byte_enable),
	.decoder_bit(decoder_out[6]),
	.out(mem_line[111:96])
);

muxarray muxarray2
(
	.line_data(array_data[95:80]),
	.mem_wdata(mem_wdata),
	.mem_byte_enable(mem_byte_enable),
	.decoder_bit(decoder_out[5]),
	.out(mem_line[95:80])
);

muxarray muxarray3
(
	.line_data(array_data[79:64]),
	.mem_wdata(mem_wdata),
	.mem_byte_enable(mem_byte_enable),
	.decoder_bit(decoder_out[4]),
	.out(mem_line[79:64])
);

muxarray muxarray4
(
	.line_data(array_data[63:48]),
	.mem_wdata(mem_wdata),
	.mem_byte_enable(mem_byte_enable),
	.decoder_bit(decoder_out[3]),
	.out(mem_line[63:48])
);

muxarray muxarray5
(
	.line_data(array_data[47:32]),
	.mem_wdata(mem_wdata),
	.mem_byte_enable(mem_byte_enable),
	.decoder_bit(decoder_out[2]),
	.out(mem_line[47:32])
);

muxarray muxarray6
(
	.line_data(array_data[31:16]),
	.mem_wdata(mem_wdata),
	.mem_byte_enable(mem_byte_enable),
	.decoder_bit(decoder_out[1]),
	.out(mem_line[31:16])
);

muxarray muxarray7
(
	.line_data(array_data[15:0]),
	.mem_wdata(mem_wdata),
	.mem_byte_enable(mem_byte_enable),
	.decoder_bit(decoder_out[0]),
	.out(mem_line[15:0])
);

endmodule : datainlogic