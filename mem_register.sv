module mem_register
(
    input clk,
    input load,
    /* inputs */
    input [width-1:0] in,//replace this with a bunch of signals
	 /* outputs */
    output logic [width-1:0] out//replace this with a bunch of signals
);

//make a bunch of these
register #(.width(2)) registername
(
    .clk,
    .load_sig_name,
    .in_name,
    .out_name
);