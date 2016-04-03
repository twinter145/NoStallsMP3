import lc3b_types::*;

module mem_register
(
    input clk,
	 input load,
    /* inputs */
    input lc3b_word ex_address,
	 input lc3b_word ex_next_instr,
	 input lc3b_control ex_control_sig,
	 input [2:0] ex_cc,
	 input lc3b_word ex_alu_out,
	 input lc3b_word ex_ir,
	 input lc3b_reg ex_dest,
	 input ex_valid,
	 /* outputs */
    output lc3b_word mem_address,
	 output lc3b_word mem_next_instr,
	 output lc3b_control mem_control_sig,
	 output [2:0] mem_cc,
	 output lc3b_word mem_alu_out,
	 output lc3b_word mem_ir,
	 output lc3b_reg mem_dest,
	 output mem_valid
);

//address
register #(.width(16)) address
(

    .clk,
    .load,
    .in(ex_address),
    .out(mem_address)
);

//next_instr
register #(.width(16)) next_instr
(
    .clk,
    .load,
    .in(ex_next_instr),
    .out(mem_next_instr)
);

//control signal
register #(.width(45)) control_signal
(
    .clk,
    .load,
    .in(ex_control_sig),
    .out(mem_control_sig)
);

//cc
register #(.width(3)) cc
(
    .clk,
    .load,
    .in(ex_cc),
    .out(mem_cc)
);

//alu out
register #(.width(16)) alu_out
(
    .clk,
    .load,
    .in(ex_alu_out),
    .out(mem_alu_out)
);

//ir
register #(.width(16)) ir
(
    .clk,
    .load,
    .in(ex_ir),
    .out(mem_ir)
);

//dest
register #(.width(3)) dest
(
    .clk,
    .load,
    .in(ex_dest),
    .out(mem_dest)
);

//valid
register #(.width(1)) valid
(
    .clk,
    .load,
    .in(ex_valid),
    .out(mem_valid)
);

endmodule : mem_register

