import lc3b_types::*;

module wb_register
(
    input clk,
	 input load,
	 /* inputs */
    input lc3b_word mem_address,
	 input lc3b_word mem_rdata,
	 input lc3b_word mem_next_instr,
	 input lc3b_control mem_control_sig,
	 input lc3b_nzp mem_cc,
	 input lc3b_word mem_alu_out,
	 input lc3b_word mem_ir,
	 input lc3b_reg mem_dest,
	 input mem_valid,
	 /* outputs */
    output lc3b_word wb_address,
	 output lc3b_word wb_rdata,
	 output lc3b_word wb_next_instr,
	 output lc3b_control wb_control_sig,
	 output lc3b_nzp wb_cc,
	 output lc3b_word wb_alu_out,
	 output lc3b_word wb_ir,
	 output lc3b_reg wb_dest,
	 output wb_valid
);

//address
register #(.width(16)) address
(
    .clk,
    .load,
    .in(mem_address),
    .out(wb_address)
);

//rdata
register #(.width(16)) rdata
(
    .clk,
    .load,
    .in(mem_rdata),
    .out(wb_rdata)
);

//next_instr
register #(.width(16)) next_instr
(
    .clk,
    .load,
    .in(mem_next_instr),
    .out(wb_next_instr)
);

//control signal
register #(.width(64)) control_signal
(
    .clk,
    .load,
    .in(mem_control_sig),
    .out(wb_control_sig)
);

//cc
register #(.width(3)) cc
(
    .clk,
    .load(clk),
    .in(mem_cc),
    .out(wb_cc)
);

//alu out
register #(.width(16)) alu_out
(
    .clk,
    .load,
    .in(mem_alu_out),
    .out(wb_alu_out)
);

//ir
register #(.width(16)) ir
(
    .clk,
    .load,
    .in(mem_ir),
    .out(wb_ir)
);

//dest
register #(.width(3)) dest
(
    .clk,
    .load,
    .in(mem_dest),
    .out(wb_dest)
);

//valid
register #(.width(1)) valid
(
    .clk,
    .load,
    .in(mem_valid),
    .out(wb_valid)
);
endmodule : wb_register

