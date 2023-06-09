import lc3b_types::*;

module arrays #(parameter width = 256)
(
    input clk,
	 input write,
    input [2:0] write_sel,
    input lc3b_c_index index,
    input [width-1:0] datain,
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
	.in(write_sel),
	.out(decode_out)
);

array #(.width(width)) way0
(
	.clk(clk),
	.write(decode_out[0] & write),
	.index(index),
	.datain(datain),
	.dataout(out0)
);

array #(.width(width)) way1
(
	.clk(clk),
	.write(decode_out[1] & write),
	.index(index),
	.datain(datain),
	.dataout(out1)
);

array #(.width(width)) way2
(
	.clk(clk),
	.write(decode_out[2] & write),
	.index(index),
	.datain(datain),
	.dataout(out2)
);

array #(.width(width)) way3
(
	.clk(clk),
	.write(decode_out[3] & write),
	.index(index),
	.datain(datain),
	.dataout(out3)
);

array #(.width(width)) way4
(
	.clk(clk),
	.write(decode_out[4] & write),
	.index(index),
	.datain(datain),
	.dataout(out4)
);

array #(.width(width)) way5
(
	.clk(clk),
	.write(decode_out[5] & write),
	.index(index),
	.datain(datain),
	.dataout(out5)
);

array #(.width(width)) way6
(
	.clk(clk),
	.write(decode_out[6] & write),
	.index(index),
	.datain(datain),
	.dataout(out6)
);

array #(.width(width)) way7
(
	.clk(clk),
	.write(decode_out[7] & write),
	.index(index),
	.datain(datain),
	.dataout(out7)
);
endmodule : arrays