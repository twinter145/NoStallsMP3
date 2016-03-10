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
	 input [1:0] ex_valid,
	 /* outputs */
    output lc3b_word mem_address,
	 output lc3b_word mem_next_instr,
	 output lc3b_control mem_control_sig,
	 output [2:0] mem_cc,
	 output lc3b_word mem_alu_out,
	 output lc3b_word mem_ir,
	 output lc3b_reg mem_dest,
	 output mem_valid,
);

//address
register #(.width(16)) address
(
    .clk,
    .load,
    .ex_address,
    .mem_address
);

//next_instr
register #(.width(16)) next_instr
(
    .clk,
    .load,
    .ex_next_instr,
    .mem_next_instr
);

//control signal
register #(.width(1)) control_signal
(
    .clk,
    .load,
    .ex_control_signal,
    .mem_control_signal
);

//cc
register #(.width(3)) cc
(
    .clk,
    .load,
    .ex_cc,
    .mem_cc
);

//alu out
register #(.width(16)) alu_out
(
    .clk,
    .load,
    .ex_alu_out,
    .mem_alu_out
);

//ir
register #(.width(16)) ir
(
    .clk,
    .load,
    .ex_ir,
    .mem_ir
);

//dest
register #(.width(3)) dest
(
    .clk,
    .load,
    .ex_dest,
    .mem_dest
);

//valid
register #(.width(1)) valid
(
    .clk,
    .load,
    .ex_valid,
    .mem_valid
);