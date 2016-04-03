import lc3b_types::*;

module ex_register
(
    input clk,
	 input load,
    /* inputs */
	 input lc3b_word de_next_instr,
	 input lc3b_control de_control_sig,
	 input [2:0] de_cc,
	 input lc3b_word de_sr1,
	 input lc3b_word de_sr2,
	 input lc3b_word de_ir,
	 input lc3b_reg de_dest,
	 input de_valid,
	 /* outputs */
	 output lc3b_word ex_next_instr,
	 output lc3b_control ex_control_sig,
	 output [2:0] ex_cc,
	 output lc3b_word ex_sr1,
	 output lc3b_word ex_sr2,
	 output lc3b_word ex_ir,
	 output lc3b_reg ex_dest,
	 output ex_valid
);

//next_instr
register #(.width(16)) next_instr
(
    .clk,
    .load,
    .in(de_next_instr),
    .out(ex_next_instr)
);

//control signal
register #(.width(46)) control_signal
(
    .clk,
    .load,
    .in(de_control_sig),
    .out(ex_control_sig)
);

//cc
register #(.width(3)) cc
(
    .clk,
    .load,
    .in(de_cc),
    .out(ex_cc)
);

//ir
register #(.width(16)) ir
(
    .clk,
    .load,
    .in(de_ir),
    .out(ex_ir)
);

//sr1
register #(.width(16)) sr1
(
    .clk,
    .load,
    .in(de_sr1),
    .out(ex_sr1)
);

//sr2
register #(.width(16)) sr2
(
    .clk,
    .load,
    .in(de_sr2),
    .out(ex_sr2)
);

//dest
register #(.width(3)) dest
(
    .clk,
    .load,
    .in(de_dest),
    .out(ex_dest)
);

//valid
register #(.width(1)) valid
(
    .clk,
    .load,
    .in(de_valid),
    .out(ex_valid)
);

endmodule : ex_register