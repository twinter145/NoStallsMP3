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
   output logic mem_read_a,
   output logic mem_write_a,
   output logic [1:0] mem_wmask_a,
   output lc3b_word mem_address_a,
   output lc3b_word mem_wdata_a,
	output logic mem_read_b,
   output logic mem_write_b,
   output logic [1:0] mem_wmask_b,
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
logic load_pc;
//decode
lc3b_control de_control_sig, control_rom_out;
lc3b_reg destmux_out, sr2_mux_out, de_dest, src1, src2;
lc3b_word de_next_instr, de_sr1, de_sr2, de_ir, irnopmux_out;
lc3b_opcode de_opcode;
logic de_valid, de_ir3, de_ir4, de_ir5, de_ir11, load_de, insert_nop;
//execute
lc3b_control ex_control_sig;
lc3b_word ex_next_instr, ex_address, ex_alu_out, ex_ir, ex_sr1, ex_sr2;
lc3b_reg ex_dest;
lc3b_nzp ex_cc;
logic ex_valid, load_ex;
//memory
lc3b_word mem_next_instr, mem_ir, ldb_mux_out, mem_mux_out, mem_addrmux_out, mem_addr_reg_out, mdr_out, ldi_mux_out;
lc3b_control mem_control_sig;
lc3b_nzp mem_cc;
lc3b_reg mem_dest;
logic mem_valid, mem_addr_mux_sel, load_address_reg, toggle, ldi_mux_sel, load_mem;
//write back
lc3b_word wb_address, wb_rdata, wb_next_instr, wb_alu_out, wb_ir, wb_data_in, wbmux_out, ldb1_mux_out, ldb_out;
lc3b_nzp wb_cc, wb_gencc_out;
lc3b_reg wb_dest;
logic wb_valid, load_wb, wb_load_cc, wb_load_reg;

assign mem_wmask_a = 2'b11;
//assign mem_wmask_b = mem_control_sig.memory_wmask;
assign mem_wdata_a = 16'b0;
assign mem_write_a = 1'b0;

//instruction port
assign mem_address_a = pc_out;


//data port
assign mem_address_b = mem_address;
//assign mem_wdata_b = mem_alu_out;

//stalls
logic memory_stall, load_register, ldi_sig, toggle_ldi;
//assign memory_stall = mem_control_sig.write_memory + mem_control_sig.read_memory;
//if A then B == B+A'
//assign load_register = clk & mem_resp_a & ((mem_resp_b & !ldi_sig) + !memory_stall);
//assign mem_read_a = load_register;
assign ldi_sig = (((mem_control_sig.opcode == op_ldi) | (mem_control_sig.opcode == op_sti)) ^ toggle_ldi);

//assign mem_read_a = clk;

//assign mem_read_b = mem_control_sig.read_memory;
//assign mem_write_b = mem_control_sig.write_memory;

///////////
/* fetch */
///////////

//logic
register pc
(
    .clk,
    .load(load_pc),
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
	.b(wb_address),
	.c(wb_rdata),
	.d(wb_data_in),
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
	.load(load_de),
	.plus2_out(plus2_out),
	.mem_rdata(mem_rdata_a),//input for ir
	//outputs
	.de_next_instr_out(de_next_instr),
	.de_dest(de_dest),
	//these scr are the index of register, de_sr# is the register value
	.src1(src1),
	.src2(src2),
	.de_opcode(de_opcode),
	.de_ir3(de_ir3),
	.de_ir4(de_ir4),
	.de_ir5(de_ir5),
	.de_ir11(de_ir11),
	.de_valid_out(de_valid),
	.de_ir_out(de_ir)
);

control_rom control_rom
(
	.opcode(de_opcode),
	.ir3(de_ir3),
	.ir4(de_ir4),
	.ir5(de_ir5),
	.ir11(de_ir11),
	.out(control_rom_out)
);

hazard_detection hazard_detection
(
	//in
	.clk(clk),
	.ir(de_ir),
	.ctrl(control_rom_out),
	.wb_ctrl(wb_control_sig),
	.mem_resp_a(mem_resp_a),
	.mem_read_a(mem_read_a),
	.mem_resp_b(mem_resp_b),
	.mem_write_b(mem_write_b),
	.mem_read_b(mem_read_b),
	.wb_dest(wb_dest),
	.ldi_sig(ldi_sig),
	//out
	.load_register(load_register),
	.load_pc(load_pc),
	.load_de(load_de),
	.load_ex(load_ex),
	.load_mem(load_mem),
	.load_wb(load_wb),
	.insert_nop(insert_nop)
);

mux2 #(.width(64)) ctrlnopmux
(
	.sel(insert_nop),
	.a(control_rom_out),
	.b(64'b0),
	.f(de_control_sig)
);

mux2 irnopmux
(
	.sel(insert_nop),
	.a(de_ir),
	.b(16'b0),
	.f(irnopmux_out)
);


mux2 #(.width(3))sr2_mux//renamed to sr2_mux
(
	.sel(de_control_sig.sr2_mux_sel),
	.a(src2),
	.b(de_dest),
	.f(sr2_mux_out)
);

mux2 #(.width(3))destmux
(
	.sel(de_control_sig.dest_mux_sel),
	.a(de_dest),
	.b(3'b111),
	.f(destmux_out)
);

cc CC
(
	 .clk,
    .in(wb_gencc_out),
	 .load_cc(wb_load_cc),
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
	.load(load_ex),
	//inputs
	.de_next_instr(de_next_instr),
	.de_control_sig(de_control_sig),
	.de_cc(cc_out),
	.de_sr1(de_sr1),
	.de_sr2(de_sr2),
	.de_ir(irnopmux_out),
	.de_dest(destmux_out),
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
	//.clk,
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
	.load(load_mem),
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
	.mem_address(mem_addr_reg_out),
	.mem_next_instr(mem_next_instr),
	.mem_control_sig(mem_control_sig),
	.mem_cc(mem_cc),
	.mem_alu_out(mem_alu_out),
	.mem_ir(mem_ir),
	.mem_dest(mem_dest),
	.mem_valid(mem_valid)
);


mux2 #(.width(16)) mem_wdata_b_mux
(
	.sel(mem_control_sig.mem_wdata_b_sel),
	.a(mem_alu_out),
	.b({mem_alu_out[7:0], mem_alu_out[7:0]}),
	.f(mem_wdata_b)
);

mux2 #(.width(2)) mem_stb_mux
(
	.sel(mem_control_sig.mem_wdata_b_sel),
	.a(mem_control_sig.memory_wmask),
	.b({mem_address[0], ~mem_address[0]}),
	.f(mem_wmask_b)
);

mux2 #(.width(16)) mem_addr_mux
(
	.sel(mem_addr_mux_sel),
	.a(mem_addr_reg_out),
	.b(mdr_out),
	.f(mem_address)
);

register mdr
(
	.clk,
	.load(mem_resp_b),
	.in(mem_rdata_b),
	.out(mdr_out)
);

mux2 ldi_mux
(
	.sel(ldi_mux_sel),
	.a(mem_rdata_b),
	.b(mdr_out),
	.f(ldi_mux_out)
);

stall_logic stall_logic
(
	.clk,
	.load_register(load_register),
	.mem_resp_a(mem_resp_a),
	.mem_resp_b(mem_resp_b),
	.write(mem_control_sig.write_memory),
	.read(mem_control_sig.read_memory),
	.opcode(mem_control_sig.opcode),
	.mem_addr_mux_sel(mem_addr_mux_sel),
	.toggle(toggle),
	.toggle_ldi(toggle_ldi),
	.ldi_mux_sel(ldi_mux_sel)
);

assign mem_read_b = mem_control_sig.read_memory ^ toggle;
assign mem_write_b = mem_control_sig.write_memory ^ toggle;

////////////////
/* write back */
////////////////

//logic
wb_register wb_regsiter
(
	.clk,
	.load(load_wb),
	//inputs
	.mem_address(mem_address),
	.mem_rdata(ldi_mux_out),
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
	.wb_cc(wb_cc),
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
	.f(wbmux_out)
);

ldb ldb
(
	.clk,
	.address(wb_address),
	.data_in(wb_rdata),
	.data_out(ldb_out)
);

mux2 ldb_mux
(
	.sel(wb_control_sig.ldb_mux_sel),
	.a(wbmux_out),
	.b(ldb_out),
	.f(wb_data_in)
);

gencc gencc
(
	.in(wb_data_in),
	.out(wb_gencc_out)
);

//added &load_register to the end of these
assign wb_load_cc = wb_control_sig.load_cc & wb_valid & load_register;
assign wb_load_reg = wb_control_sig.load_regfile & wb_valid;

endmodule : datapath
