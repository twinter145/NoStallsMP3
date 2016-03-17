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
			out = 1;
		else
			out = 0;
	end
	else out = 0;
end

endmodule : fetch_logic
