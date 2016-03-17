import lc3b_types::*;

module arrays #(parameter width = width)
(
    input clk,
    input [2:0] write,
    input lc3b_c_index index,
    input lc3b_d_line datain,
    output logic [width-1:0] out0,
    output logic [width-1:0] out1,
    output logic [width-1:0] out2,
    output logic [width-1:0] out3,
    output logic [width-1:0] out4,
    output logic [width-1:0] out5,
    output logic [width-1:0] out6,
    output logic [width-1:0] out7
);

lc3b_byte decode_out;

decoder write_decode
(
	.in(write),
	.out(decode_out)
);

array #(.width(width)) way0
(
	.clk(clk),
	.write(decode_out[0]),
	.index(index),
	.datain(datain),
	.dataout(out0)
);

array #(.width(width)) way1
(
	.clk(clk),
	.write(decode_out[1]),
	.index(index),
	.datain(datain),
	.dataout(out1)
);

array #(.width(width)) way2
(
	.clk(clk),
	.write(decode_out[2]),
	.index(index),
	.datain(datain),
	.dataout(out2)
);

array #(.width(width)) way3
(
	.clk(clk),
	.write(decode_out[3]),
	.index(index),
	.datain(datain),
	.dataout(out3)
);

array #(.width(width)) way4
(
	.clk(clk),
	.write(decode_out[4]),
	.index(index),
	.datain(datain),
	.dataout(out4)
);

array #(.width(width)) way5
(
	.clk(clk),
	.write(decode_out[5]),
	.index(index),
	.datain(datain),
	.dataout(out5)
);

array #(.width(width)) way6
(
	.clk(clk),
	.write(decode_out[6]),
	.index(index),
	.datain(datain),
	.dataout(out6)
);

array #(.width(width)) way7
(
	.clk(clk),
	.write(decode_out[7]),
	.index(index),
	.datain(datain),
	.dataout(out7)
);
endmodule : arrays