import lc3b_types::*;

module hazard_detection
(
	input clk,
	
	input lc3b_word ir,
	input lc3b_control ctrl, wb_ctrl,
	input lc3b_reg wb_dest,
	input logic mem_resp_a, mem_resp_b, mem_write_b, mem_read_b, ldi_sig,
	
	output logic mem_read_a, load_pc, load_de, load_ex, load_mem, load_wb, load_register, insert_nop
);
lc3b_opcode opcode;
lc3b_reg sr1, sr2, dest;

lc3b_byte register_valid;

logic store_instr;

assign opcode = lc3b_opcode'(ir[15:12]);
assign dest = ir[11:9];
assign sr1 = ir[8:6];
assign sr2 = ir[2:0];
always_comb
begin
	if((opcode == op_str) || (opcode == op_sti) || (opcode == op_stb))
		store_instr = 1;
	else
		store_instr = 0;
end

register_scoreboard scoreboard
(
	.clk(clk),
	.write0(ctrl.uses_dest),
	.index0(dest),
	.write1(wb_ctrl.uses_dest),
	.index1(wb_dest),
	.dataout(register_valid)
);

logic data_hazard, hazard, load_start, load_end;
//if this uses sr1 and sr1 is currently invalid, or same for sr2 or store instruction
assign data_hazard = ( (ctrl.uses_sr1 & (!register_valid[sr1]) ) | (ctrl.uses_sr2 & (!register_valid[sr2]) ) | (store_instr & (!register_valid[dest])));

always_ff @ (posedge clk)
begin
	mem_read_a = 1'b1;
	if(mem_resp_a == 1'b1)
		mem_read_a = 1'b0;
	else if(load_register == 1'b1)
		mem_read_a = 1'b1;
end

//stalls
logic memory_stall;
assign memory_stall = (mem_write_b + mem_read_b); //& (!mem_resp_b);
//if A then B == B+A'
//assign load_register = clk & (mem_resp_a + !mem_read_a) & (!memory_stall);
assign load_register = mem_resp_a & ((mem_resp_b & !ldi_sig) + !memory_stall);


assign hazard = data_hazard; //| ctrl.branch;

/*
assign load_pc = load_de & mem_resp_a;
assign load_de = load_ex & (!hazard);
assign load_ex = load_mem;
assign load_mem = load_wb;
assign load_wb = clk&(!memory_stall);
*/

assign load_start = load_register & (!hazard);
assign load_end = load_register;

assign load_pc = load_start;
assign load_de = load_start;
assign load_ex = load_end;
assign load_mem = load_end;
assign load_wb = load_end;

assign insert_nop = hazard;
	
endmodule : hazard_detection