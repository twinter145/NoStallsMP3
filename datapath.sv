import lc3b_types::*;

module datapath
(
	input clk,

	/* memory signals */
	//inputs
	input mem_resp_a,
   input lc3b_word mem_rdata_a,
	input mem_resp_b,
   input lc3b_word mem_rdata_b,
   //outputs
   output mem_read_a,
   output mem_write_a,
   output [1:0] mem_wmask_a,
   output lc3b_word mem_address_a,
   output lc3b_word mem_wdata_a,
	output mem_read_b,
   output mem_write_b,
   output [1:0] mem_wmask_b,
   output lc3b_word mem_address_b,
   output lc3b_word mem_wdata_b
	
	/* other stuff */
	//inputs
	
	//outputs
);
//////////////////////
/* internal signals */
//////////////////////
//fetch
lc3b_control wb_control_sig;
lc3b_word plus2_out, pcmux_out, mem_trap, pc_out, mem_alu_out, mem_address;
lc3b_mux_sel pcmux_sel;
lc3b_nzp cc_out;
//decode
lc3b_control de_control_sig; //worry about size later
lc3b_reg destmux_out, sr2_mux_out, de_dest, src1, src2;
lc3b_word de_next_instr, de_sr1, de_sr2, de_ir;
lc3b_opcode de_opcode;
logic de_valid_out, de_ir5, de_ir11;
//execute
lc3b_control ex_control_sig;
lc3b_word ex_next_instr, ex_address, ex_alu_out, ex_ir, ex_sr1, ex_sr2;
lc3b_reg ex_dest;
lc3b_nzp ex_cc;
logic ex_valid;
//memory
lc3b_word mem_next_instr, mem_ir;
lc3b_control mem_control_sig;
lc3b_nzp mem_cc;
lc3b_reg mem_dest;
logic mem_valid;
//write back
lc3b_word wb_address, wb_rdata, wb_next_instr, wb_alu_out, wb_ir, wb_data_in;
lc3b_nzp wb_cc;
lc3b_reg wb_dest;
logic wb_valid, wb_load_cc, wb_load_reg;

assign mem_wmask_a = 2'b11;
assign mem_wmask_b = 2'b11;

//instruction port
assign mem_address_a = pc_out;
assign mem_read_a = clk;//load every cycle

//data port
assign mem_address_b = mem_address;
assign mem_wdata_b = mem_alu_out;


///////////
/* fetch */
///////////

//logic
register pc
(
    .clk,
    .load(clk),
    .in(pcmux_out),
    .out(pc_out)
);

fetch_logic fetch_logic
(
	.ir_9_11(wb_ir[11:9]),
	.cc(wb_cc),
	.opcode(wb_control_sig.opcode),
	.out(pcmux_sel)
);

mux4 pcmux
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

////////////
/* decode */
////////////

//logic
de_register de_register
(
	//inputs
	.clk,
	.plus2_out(plus2_out),
	.mem_rdata(mem_rdata_a),//input for ir
	//outputs
	.de_next_instr_out(de_next_instr),
	.de_dest(de_dest),
	//these scr are the index of register, de_sr# is the register value
	.src1(src1),
	.src2(src2),
	.de_opcode(de_opcode),
	.de_ir5(de_ir5),
	.de_ir11(de_ir11),
	.de_valid_out(de_valid),
	.de_ir_out(de_ir)
);

control_rom control_rom
(
	.opcode(de_opcode),
	.ir5(de_ir5),
	.ir11(de_ir11),
	.out(de_control_sig)
);

mux2 #(.width(3))sr2_mux//renamed to sr2_mux
(
	.sel(de_control_sig.sr2_mux_sel),
	.a(src2),
	.b(de_dest),
	.f(sr2_mux_out)
);

/*
mux2 #(.width(3))destmux
(
	.sel(de_control_sig.dest_mux_sel),
	.a(de_dest),
	.b(3'b111),
	.f(destmux_out)
);
*/
/*
cc CC
(
	 .clk,
    .in(wb_cc),
	 .load_cc(wb_load_cc),
    .out(cc_out)
);
*/
register #(.width(3)) cc
(
	.clk,
	.load(wb_load_cc),
	.in(wb_cc),
	.out(cc_out)
);

regfile regfile
(
	//in
	.clk,
	.load(wb_load_reg),//is this the right name?
	.in(wb_data_in),
	.src_a(src1),
	.src_b(sr2_mux_out),
	.dest(wb_dest),
	//out
	.reg_a(de_sr1),
	.reg_b(de_sr2)
);


/////////////
/* execute */
/////////////

//logic
ex_register ex_register
(
	.clk,
	//inputs
	.de_next_instr(de_next_instr),
	.de_control_sig(de_control_sig),
	.de_cc(cc_out),
	.de_sr1(de_sr1),
	.de_sr2(de_sr2),
	.de_ir(de_ir),
	.de_dest(de_dest),
	.de_valid(de_valid),
	//outputs
	.ex_next_instr(ex_next_instr),
	.ex_control_sig(ex_control_sig),
	.ex_cc(ex_cc),
	.ex_sr1(ex_sr1),
	.ex_sr2(ex_sr2),
	.ex_ir(ex_ir),
	.ex_dest(ex_dest),
	.ex_valid(ex_valid)
);

ex_logic ex_logic
(
	//inputs
	.ex_control_sig(ex_control_sig),
	.ex_next_instruction(ex_next_instr),
	.ex_ir(ex_ir),
	.ex_sr1(ex_sr1),
	.ex_sr2(ex_sr2),
	//outputs
	.ex_address(ex_address),
	.ex_alu_out(ex_alu_out)
);

////////////
/* memory */
////////////

//logic
mem_register mem_register 
(
	.clk,
	//inputs
	.ex_address(ex_address),
	.ex_next_instr(ex_next_instr),
	.ex_control_sig(ex_control_sig),
	.ex_cc(ex_cc),
	.ex_alu_out(ex_alu_out),
	.ex_ir(ex_ir),
	.ex_dest(ex_dest),
	.ex_valid(ex_valid),
	//outputs
	.mem_address(mem_address),
	.mem_next_instr(mem_next_instr),
	.mem_control_sig(mem_control_sig),
	.mem_cc(mem_cc),
	.mem_alu_out(mem_alu_out),
	.mem_ir(mem_ir),
	.mem_dest(mem_dest),
	.mem_valid(mem_valid)
);

assign mem_read_b = mem_control_sig.read_memory;
assign mem_write_b = mem_control_sig.write_memory;

////////////////
/* write back */
////////////////

//logic
wb_register wb_regsiter
(
	.clk,
	//inputs
	.mem_address(mem_address),
	.mem_rdata(mem_rdata_b),
	.mem_next_instr(mem_next_instr),
	.mem_control_sig(mem_control_sig),
	.mem_cc(mem_cc),
	.mem_alu_out(mem_alu_out),
	.mem_ir(mem_ir),
	.mem_dest(mem_dest),
	.mem_valid(mem_valid),
	//outputs
	.wb_address(wb_address),
	.wb_rdata(wb_rdata),
	.wb_next_instr(wb_next_instr),
	.wb_control_sig(wb_control_sig),
	//.wb_cc(wb_cc),
	.wb_alu_out(wb_alu_out),
	.wb_ir(wb_ir),
	.wb_dest(wb_dest),
	.wb_valid(wb_valid)
);

mux4 wb_mux
(
	.sel(wb_control_sig.wb_mux_sel),
	.a(wb_address),
	.b(wb_rdata),
	.c(wb_next_instr),
	.d(wb_alu_out),
	.f(wb_data_in)
);

gencc gencc
(
	.in(wb_data_in),
	.out(wb_cc)
);

assign wb_load_cc = wb_control_sig.load_cc&wb_valid;
assign wb_load_reg = wb_control_sig.load_regfile&wb_valid;

endmodule : datapath
