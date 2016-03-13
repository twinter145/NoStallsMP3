import lc3b_types::*;

module de_register
(
    /* inputs */
    input clk,
	 input lc3b_word plus2_out,
	 input lc3b_word mem_rdata,
	 
	 /* outputs */
	 output lc3b_word de_next_instr_out,
	 output lc3b_reg de_dest,
	 output lc3b_reg src1,
	 output lc3b_reg src2,
	 output lc3b_opcode de_opcode,
	 output logic de_ir5,
	 output logic de_ir11,
	 output logic de_valid_out,
	 output lc3b_word de_ir_out
);

register #(.width(16)) de_next_instr
(
	.clk,
	.load(clk),
	.in(plus2_out),
	.out(de_next_instr_out)
);
 
ir IR //reference input/output names
(
	//inputs
	.clk,
	.load(clk),
	.in(mem_rdata),
	.out(de_ir_out),
	.opcode(de_opcode),
	.dest(de_dest),
	.src1(src1),
	.src2(src2),
	.ir5(de_ir5),
	.ir11(de_ir11)
);

register #(.width(1)) de_valid
(
	.clk,
	.load(clk),
	.in(1'b1),
	.out(de_valid_out)
);

endmodule : de_register