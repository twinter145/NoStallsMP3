import lc3b_types::*;

module datapath
(
	input clk,

	/* memory signals */
	//inputs
	input mem_resp,
	input lc3b_word mem_rdata,
	//outputs
	output mem_read,
	output mem_write,
	output lc3b_mem_wmask mem_byte_enable,
	output lc3b_word mem_address,
	output lc3b_word mem_wdata
	
	/* other stuff */
	//inputs
	
	//outputs
);

//internal signals
lc3b_word wb_mux_out;

//internal signals
lc3b_word plus2_out;
lc3b_word mem_rdata;
lc3b_word de_next_instr_out;
lc3b_reg dest;
lc3b_reg destmux_out;
lc3b_reg srmux_out;
lc3b_reg src1;
lc3b_reg src2;
lc3b_opcode opcode;
logic ir5;
logic ir11;
logic de_valid_out;
lc3b_word pcmux_out;
lc3b_mem_wmask mem_byte_enable;
lc3b_mux_sel pcmux_sel;
lc3b_word mem_address;
lc3b_word mem_trap;
lc3b_word pc_out;
lc3b_word de_control_signal; //worry about size later
lc3b_nzp wb_cc;
logic wb_load_cc;
lc3b_nzp cc_out;

//fetch
register pc
(
    .clk,
    .load(clk),
    .in(pcmux_out),
    .out(pc_out)
);

fetch_logic fetch_logic
(
	.in(mem_byte_enable),
	.out(pcmux_sel)
);

mux3 pcmux
(
	.sel(pcmux_sel),
	.a(plus2_out),
	.b(mem_address),
	.c(mem_trap),
	.f(pcmux_out)
);

plus2 plus2
(
	.in(pc_out),
	.out(plus2_out)
);

de_register de_register
(
	.clk,
	.plus2_out(plus2_out),
	.mem_rdata(mem_rdata),
	.de_next_instr_out(de_next_instr_out),
	.dest(dest),
	.src1(src1),
	.src2(src2),
	.opcode(opcode),
	.ir5(ir5),
	.ir11(ir11),
	.de_valid_out(de_valid_out)
);

//decode

control_rom control_rom
(
	.opcode(opcode),
	.ir5(ir5),
	.ir11(ir11),
	.control_signal(de_control_signal)
);

mux2 #(.width(3))srmux
(
	.sel(de_control_signal[0]),
	.a(src2),
	.b(dest),
	.f(srmux_out)
);

mux2 #(.width(3))destmux
(
	.sel(de_control_signal[0]),
	.a(dest),
	.b(3'b111),
	.f(destmux_out)
);

cc CC
(
	 .clk,
    .in(wb_cc),
	 .load_cc(wb_load_cc),
    .out(cc_out)
);



//execute


//memory
mem_register mem_register 
(
	.clk
	.load
);

memory memory
(
);

//write back
wb_register wb_regsiter
(
	.clk,
	.load,
);

mux4 wb_mux
(
	.sel(wb_mux_sel),
	.a(wb_address_out),
	.b(wb_rdata_out),
	.c(wb_next_instr_out),
	.d(wb_alu_out),
	.f(wb_mux_out)
);

gencc gencc
(
	.in(wb_mux_out),
	.out(gencc_out)
);

endmodule : datapath
