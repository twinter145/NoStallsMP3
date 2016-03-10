module de_register
(
    /* inputs */

    input clk,
	 input lc3b_word plus2_out,
	 input mem_rdata,
	 
	 /* outputs */
	 output lc3b_word de_next_instr_out,
	 output lc3b_reg dest,
	 output lc3b_reg src1,
	 output lc3b_reg src2,
	 output lc3b_opcode opcode,
	 output logic ir5,
	 output logic ir11,
	 output logic de_valid_out,
	 output lc3b_word ir_out
);


//make a bunch of these
register #(.width(16)) de_next_instr
(
    .clk,
    .load(clk),
    .in(plus2_out),
    .out(de_next_instr_out)
);
 
ir IR //reference input/output names
(
    .clk,
    .load(clk),
    .in(mem_rdata),
	 .out(ir_out),
    .opcode(opcode),
    .dest(dest), 
	 .src1(src1), 
	 .src2(src2),
	 .ir5(ir5),
	 .ir11(ir11)
);

register #(.width(1)) de_valid
(
    .clk,
    .load(clk),
    .in(1'b1),
    .out(de_valid_out)
);

endmodule : de_register