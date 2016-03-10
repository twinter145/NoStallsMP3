module wb_register
(
    input clk,
    input load
	 /* inputs */
    input lc3b_word mem_address,
	 input lc3b_word mem_rdata,
	 input lc3b_word mem_next_instr,
	 input lc3b_control mem_control_sig,
	 input [2:0] mem_cc,
	 input lc3b_word mem_alu_out in,
	 input lc3b_word mem_ir in,
	 input lc3b_reg mem_dest,
	 input [1:0] mem_valid,
	 /* outputs */
    output lc3b_word wb_address,
	 output lc3b_word wb_rdata,
	 output lc3b_word wb_next_instr,
	 output lc3b_control wb_control_sig,
	 output [2:0] wb_cc,
	 output lc3b_word wb_alu_out,
	 output lc3b_word wb_ir,
	 output lc3b_reg wb_dest,
	 output wb_valid,
);

//address
register #(.width(16)) address
(
    .clk,
    .load,
    .mem_address,
    .wb_address
);

//rdata
register #(.width(16)) rdata
(
    .clk,
    .load,
    .mem_rdata,
    .wb_rdata
);

//next_instr
register #(.width(16)) next_instr
(
    .clk,
    .load,
    .mem_next_instr,
    .wb_next_instr
);

//control signal
register #(.width(1)) control_signal
(
    .clk,
    .load,
    .mem_control_signal,
    .wb_control_signal
);

//cc
register #(.width(3)) cc
(
    .clk,
    .load,
    .mem_cc,
    .wb_cc
);

//alu out
register #(.width(16)) alu_out
(
    .clk,
    .load,
    .mem_alu_out,
    .wb_alu_out
);

//ir
register #(.width(16)) ir
(
    .clk,
    .load,
    .mem_ir,
    .wb_ir
);

//dest
register #(.width(3)) dest
(
    .clk,
    .load,
    .mem_dest,
    .wb_dest
);

//valid
register #(.width(1)) valid
(
    .clk,
    .load,
    .mem_valid,
    .wb_valid
);
endmodule : wb_register

