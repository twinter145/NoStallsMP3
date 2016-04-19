import lc3b_types::*;

module hazard_detection
(
	input clk,
	
	input lc3b_word ir,
	input lc3b_control ctrl, wb_ctrl,
	input lc3b_reg wb_dest,
	input logic mem_resp_a, mem_resp_b, mem_write_b, mem_read_b, ldi_sig, br_taken,
	
	output logic mem_read_a, load_pc, load_de, load_ex, load_mem, load_wb, load_register, insert_nop
);
lc3b_opcode opcode;
lc3b_reg sr1, sr2, dest;

lc3b_byte register_valid;

logic store_instr, mem_miss_a, mem_miss_b;
logic [1:0] br_stall_count;
logic br_taken_count;
logic wb_stall;
logic data_hazard, hazard, load_start, load_end;

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
	.mem_miss_a(mem_miss_a),
	.mem_miss_b(mem_miss_b),
	.br_taken(br_taken),
	.br_taken_count(br_taken_count),
	.br_stall_count(br_stall_count),
	.write0(ctrl.uses_dest),
	.index0(dest),
	.write1(wb_ctrl.uses_dest),
	.index1(wb_dest),
	.dataout(register_valid)
);

/*
always_ff @ (posedge clk)
begin
	br_stall_count = 0;
	case(br_stall_count)
		2'b00: begin
			if(opcode == op_br)
				br_stall_count = 2'b01;
		end
		
		2'b01: begin
			br_stall_count = 2'b10;
		end
		
		2'b10: begin
			br_stall_count = 2'b11;
		end
		
		2'b11: begin
			br_stall_count = 2'b00;
		end
		
		default: ;
	endcase
end
*/

always_ff @ (posedge clk)
begin
	if(br_stall_count == 2'b01)
		br_stall_count = 2;
	else if(br_stall_count == 2'b10)
	begin
		if(mem_miss_b == 1)
			br_stall_count = 2;
		else
			br_stall_count = 3;
	end
	else if(br_stall_count == 2'b11)
		br_stall_count = 0;
	else if(opcode == op_br || opcode == op_jmp || opcode == op_jsr || opcode == op_trap)
		br_stall_count = 1;
	else
		br_stall_count = 0;
end

always_ff @ (posedge clk)
begin
	if(br_taken == 1 || (br_taken_count == 1 && mem_miss_a == 1))
		br_taken_count = 1;
	else
		br_taken_count = 0;
end

//if this uses sr1 and sr1 is currently invalid, or same for sr2 or store instruction
assign data_hazard = ( (ctrl.uses_sr1 & (!register_valid[sr1]) ) | (ctrl.uses_sr2 & (!register_valid[sr2]) ) | (store_instr & (!register_valid[dest])));

assign mem_miss_a = mem_read_a & ~mem_resp_a;
assign mem_miss_b = ((mem_write_b | mem_read_b) & ~mem_resp_b) | ldi_sig;
assign wb_stall = mem_miss_a & br_taken;

assign mem_read_a = 1'b1 & ~hazard;

assign load_register = 1'b1 & ~mem_miss_b & ~wb_stall;

assign hazard = data_hazard; //| ctrl.branch;

assign load_start = load_register & (~insert_nop | br_taken | (br_taken_count & ~mem_miss_a));
assign load_end = load_register;

assign load_pc = load_start;
assign load_de = load_start;
assign load_ex = load_end;
assign load_mem = load_end;
assign load_wb = load_end;

always_comb
begin
	if((hazard == 1) || (mem_miss_a == 1) || (br_stall_count != 0) || (br_taken == 1) || (br_taken_count == 1))
		insert_nop = 1;
	else
		insert_nop = 0;
end
//assign insert_nop = hazard | mem_miss_a;
	
endmodule : hazard_detection