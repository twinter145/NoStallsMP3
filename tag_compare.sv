import lc3b_types::*;

module tag_compare #(parameter width = 11)
(
	input lc3b_L2_tag tag,
	
	input [width-1:0] in0,
	input [width-1:0] in1,
	input [width-1:0] in2,
	input [width-1:0] in3,
	input [width-1:0] in4,
	input [width-1:0] in5,
	input [width-1:0] in6,
	input [width-1:0] in7,

	output lc3b_byte result
);

compare #(.width(11)) compare0
(
	.a(in0),
	.b(tag),
	.f(result[0])
);

compare #(.width(11)) compare1
(
	.a(in1),
	.b(tag),
	.f(result[1])
);

compare #(.width(11)) compare2
(
	.a(in2),
	.b(tag),
	.f(result[2])
);

compare #(.width(11)) compare3
(
	.a(in3),
	.b(tag),
	.f(result[3])
);

compare #(.width(11)) compare4
(
	.a(in4),
	.b(tag),
	.f(result[4])
);

compare #(.width(11)) compare5
(
	.a(in5),
	.b(tag),
	.f(result[5])
);

compare #(.width(11)) compare6
(
	.a(in6),
	.b(tag),
	.f(result[6])
);

compare #(.width(11)) compare7
(
	.a(in7),
	.b(tag),
	.f(result[7])
);


endmodule : tag_compare