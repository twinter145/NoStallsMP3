import lc3b_types::*;

module mp3
(
    input clk,

    /* Memory signals */
    input mem_resp,
    input lc3b_word mem_rdata,
    output mem_read,
    output mem_write,
    output lc3b_mem_wmask mem_byte_enable,
    output lc3b_word mem_address,
    output lc3b_word mem_wdata
);

lc3b_aluop aluop1;
lc3b_opcode opcode1;
lc3b_nzp branch_enable;
lc3b_mux_sel marmux_sel;
lc3b_mux_sel mdrmux_sel;
lc3b_mux8_sel alumux_sel;
lc3b_mux_sel pcmux_sel;
lc3b_mux8_sel regfilemux_sel;
lc3b_mux_sel addr2mux_sel;
logic ir51;
logic ir61;
logic ir111;
logic mar01;

/* Instantiate MP 0 top level blocks here */

datapath datapath
(
	.clk,
	.pcmux_sel(pcmux_sel),
	.load_pc(load_pc),
	.marmux_sel(marmux_sel),
	.load_mar(load_mar),
	.mdrmux_sel(mdrmux_sel),
	.load_mdr(load_mdr),
	.mem_rdata(mem_rdata),
	.mem_address(mem_address),
	.mem_wdata(mem_wdata),
	.load_ir(load_ir),
	.opcode(opcode1),
	.storemux_sel(storemux_sel),
	.load_regfile(load_regfile),
	.alumux_sel(alumux_sel),
	.aluop(aluop1),
	.load_cc(load_cc),
	.regfilemux_sel(regfilemux_sel),
	.branch_enable(branch_enable),
	.ir5(ir51),
	.ir6(ir61),
	.ir11(ir111),
	.destmux_sel(destmux_sel),
	.addr2mux_sel(addr2mux_sel),
	.mar0(mar01)
);

control control
(
	.clk,
	.opcode(opcode1),
	.load_pc(load_pc),
	.load_ir(load_ir),
	.load_regfile(load_regfile),
	.load_mar(load_mar),
	.load_mdr(load_mdr),
	.load_cc(load_cc),
	.pcmux_sel(pcmux_sel),
	.storemux_sel(storemux_sel),
	.alumux_sel(alumux_sel),
	.regfilemux_sel(regfilemux_sel),
	.marmux_sel(marmux_sel),
	.mdrmux_sel(mdrmux_sel),
	.aluop(aluop1),
	.mem_resp(mem_resp),
	.mem_read(mem_read),
	.mem_write(mem_write),
	.mem_byte_enable(mem_byte_enable),
	.branch_enable(branch_enable),
	.ir5(ir51),
	.ir6(ir61),
	.ir11(ir111),
	.destmux_sel(destmux_sel),
	.addr2mux_sel(addr2mux_sel),
	.mar0(mar01)
);


endmodule : mp3
