import lc3b_types::*;

module datapath
(
	/* control signals */
	 input clk,
	 
	 //PC
	 //input logic pcmux_sel,
	 input logic load_pc,
	 
	 //MAR/MDR
	 input lc3b_mux_sel marmux_sel,
	 input logic load_mar,
	 input lc3b_mux_sel mdrmux_sel,
	 input logic load_mdr,
	 input lc3b_word mem_rdata,
	 output lc3b_word mem_address,
	 output lc3b_word mem_wdata,
	 
	 //IR
	 input logic load_ir,
	 output lc3b_opcode opcode,
	 input logic storemux_sel,
	 
	 //ALU/REGFILE
	 input logic load_regfile,
	 //input logic alumux_sel,
	 input lc3b_aluop aluop,
	 
	 //CC
	 input logic load_cc,
	 output lc3b_nzp branch_enable,
	 
	 //new
	 output logic ir5,
	 output logic ir6,
	 output logic ir11,
	 input lc3b_mux8_sel alumux_sel,
	 input lc3b_mux_sel pcmux_sel,
	 input lc3b_mux8_sel regfilemux_sel,
	 input logic destmux_sel,
	 input lc3b_mux_sel addr2mux_sel,
	 output mar0
);

/* declare internal signals */
//PC
lc3b_word pcmux_out;
lc3b_word pc_out;
lc3b_word br_add_out;
lc3b_word pc_plus2_out;

//MAR/MDR
lc3b_word marmux_out;
lc3b_word mdrmux_out;

//IR
lc3b_reg sr1;
lc3b_reg sr2;
lc3b_reg dest;
lc3b_reg destmux_out;
lc3b_reg storemux_out;
lc3b_offset9 offset9;
lc3b_offset6 offset6;
lc3b_offset11 offset11;
lc3b_trapvect8 trapvect8;
lc3b_word adj9_out;
lc3b_word adj6_out;
lc3b_word adj11_out;
lc3b_word sext5_out;
lc3b_word sext6_out;
lc3b_word addr2mux_out;

//ALU/REGFILE
lc3b_word regfile_outa;
lc3b_word regfile_outb;
lc3b_word alumux_out;
lc3b_word alu_out;

//CC
lc3b_word regfilemux_out;
lc3b_nzp gencc_out;
lc3b_reg cc_out;

//
lc3b_imm5 imm5;
lc3b_imm4 imm4;

assign mar0 = mem_address[0];

/* instantiate components */
//PC
mux4 pcmux
(
    .sel(pcmux_sel),
    .a(pc_plus2_out),
    .b(br_add_out),
	 .c(alu_out),
	 .d(mem_wdata),
    .f(pcmux_out)
);

register pc
(
    .clk,
    .load(load_pc),
    .in(pcmux_out),
    .out(pc_out)
);

plus2 pcplus2
(
	.in(pc_out),
	.out(pc_plus2_out)
);

adder br_add
(
	.a(addr2mux_out),
	.b(pc_out),
	.f(br_add_out)
);

mux4 addr2mux
(
	.sel(addr2mux_sel),
	.a(adj9_out),
	.b(adj11_out),
	.c(),//
	.d(),//
	.f(addr2mux_out)
);

adj #(.width(11)) adj11
(
	.in(offset11),
	.out(adj11_out)
);

//MAR/MDR
mux4 marmux
(
	.sel(marmux_sel),
	.a(alu_out),
	.b(pc_out),
	.c({7'b0000000, trapvect8, 1'b0}),
	.d(mem_wdata),
	.f(marmux_out)
);

register mar
(
	.clk,
   .load(load_mar),
	.in(marmux_out),
	.out(mem_address)
);

mux4 mdrmux
(
	.sel(mdrmux_sel),
	.a(alu_out),
	.b(mem_rdata),
	.c({8'b00000000,alu_out[7:0]}),//low
	.d({alu_out[7:0],8'b00000000}),//high
	.f(mdrmux_out)
);

register mdr
(
	.clk,
   .load(load_mdr),
	.in(mdrmux_out),
	.out(mem_wdata)
);


//IR
mux2 #(.width(3)) storemux
(
	.sel(storemux_sel),
	.a(sr1),
	.b(dest),
	.f(storemux_out)
);

adj #(.width(9)) adj9
(
	.in(offset9),
	.out(adj9_out)
);

adj #(.width(6)) adj6
(
	.in(offset6),
	.out(adj6_out)
);

ir ir
(
	.clk,
   .load(load_ir),
   .in(mem_wdata),
   .opcode(opcode),
   .dest(dest),
	.src1(sr1),
	.src2(sr2),
   .offset6(offset6),
	.offset9(offset9),
	.offset11(offset11),
	.trapvect8(trapvect8),
	.imm5(imm5),
	.imm4(imm4),
	.ir5(ir5),
	.ir6(ir6),
	.ir11(ir11)
);

mux2 #(.width(3)) destmux
(
	.sel(destmux_sel),
	.a(dest),
	.b(3'b111),
	.f(destmux_out)
);

//ALU/REGFILE
regfile regfile
(
	.clk,
	.load(load_regfile),
	.in(regfilemux_out),
	.src_a(storemux_out),
	.src_b(sr2),
	.dest(destmux_out),
	.reg_a(regfile_outa),
	.reg_b(regfile_outb)
);

mux8 alumux
(
    .sel(alumux_sel),
    .a(regfile_outb),
    .b(adj6_out),
	 .c(sext5_out),
	 .d({12'b0, imm4}),
	 .e(sext6_out),
	 .g(),
	 .h(),
	 .i(),
    .f(alumux_out)
);

sext #(.width(6)) sext6
(
	.in(offset6),
	.out(sext6_out)
);

sext #(.width(5)) sext5
(
	.in(imm5),
	.out(sext5_out)
);

alu alu
(
	.aluop(aluop),
	.a(regfile_outa),
	.b(alumux_out),
	.f(alu_out)
);

//CC
mux8 regfilemux
(
    .sel(regfilemux_sel),
    .a(alu_out),
    .b(mem_wdata),
	 .c(br_add_out),
	 .d(pc_out),
	 .e({8'b00000000, mem_wdata[7:0]}),//low
	 .g({8'b00000000, mem_wdata[15:8]}),//high
    .f(regfilemux_out)
);

gencc gencc
(
	.in(regfilemux_out),
	.out(gencc_out)
);

register #(.width(3)) cc
(
	.clk,
	.load(load_cc),
	.in(gencc_out),
	.out(cc_out)
);

comparator #(.width(3)) comparator
(
	.a(dest),
	.b(cc_out),
	.f(branch_enable)
);

endmodule : datapath
