import lc3b_types::*;

module fetch_logic
(
    input lc3b_nzp ir_9_11,
	 input lc3b_nzp cc,
	 input lc3b_opcode opcode,
	 input logic ir8,
	 output lc3b_mux_sel out,
	 output logic br_taken
);

always_comb
begin
	if((((ir_9_11 & cc) > 0) && opcode == op_br) || (opcode == op_jmp || opcode == op_jsr || (opcode == op_trap&&(~ir8))))
		br_taken = 1;
	else
		br_taken = 0;
end

always_comb
begin
	if (opcode == op_br) 
	begin
		if (br_taken == 1)
			out = 2'b01;
		else
			out = 2'b00;
	end
	else if(opcode == op_trap)
		out = 2'b10;
	else if(opcode == op_jmp)
		out = 2'b11;
	else if (opcode == op_jsr)
	begin
		out = 2'b01;//unconditional jump
	end
	else out = 2'b00;
end

endmodule : fetch_logic
