import lc3b_types::*;

module fetch_logic
(
    input lc3b_nzp ir_9_11,
	 input lc3b_nzp cc,
	 input lc3b_opcode opcode,
	 output lc3b_mux_sel out
);

always_comb
begin
	if (opcode == op_br) 
	begin
		if ((ir_9_11&cc) > 0)
			out = 2'b01;
		else
			out = 2'b00;
	end
	else if(opcode == op_trap)
		out = 2'b10;
	else if(opcode == op_jmp)
		out = 2'b11;
	else
		out = 2'b00;
end

endmodule : fetch_logic
