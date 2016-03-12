module ex_register
(
    input clk,
    input load
    /* inputs */
	 input lc3b_word de_next_instr,
	 input lc3b_control de_control_sig,
	 input [2:0] de_cc,
	 input lc3b_word sr1,
	 input lc3b_word sr2,
	 input lc3b_word de_ir,
	 input lc3b_reg de_dest,
	 input [1:0] de_valid,
	 /* outputs */
	 output lc3b_word ex_next_instr,
	 output lc3b_control ex_control_sig,
	 output [2:0] ex_cc,
	 output lc3b_word sr1,
	 output lc3b_word sr2,
	 output lc3b_word ex_ir,
	 output lc3b_reg ex_dest,
	 output ex_valid,
);

//next_instr
register #(.width(16)) next_instr
(
    .clk,
    .load,
    .de_next_instr,
    .ex_next_instr
);

//control signal
register #(.width(1)) control_signal
(
    .clk,
    .load,
    .de_control_signal,
    .ex_control_signal
);

//cc
register #(.width(3)) cc
(
    .clk,
    .load,
    .de_cc,
    .ex_cc
);

//ir
register #(.width(16)) ir
(
    .clk,
    .load,
    .de_ir,
    .ex_ir
);

//sr1
register #(.width(16)) sr1
(
    .clk,
    .load,
    .de_sr1,
    .ex_sr1
);

//sr2
register #(.width(16)) sr2
(
    .clk,
    .load,
    .de_sr2,
    .ex_sr2
);

//dest
register #(.width(3)) dest
(
    .clk,
    .load,
    .de_dest,
    .ex_dest
);

//valid
register #(.width(1)) valid
(
    .clk,
    .load,
    .de_valid,
    .ex_valid
);

endmodule : ex_register