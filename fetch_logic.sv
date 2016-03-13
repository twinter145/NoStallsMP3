import lc3b_types::*;

module fetch_logic
(
    input logic [2:0] ir_9_11, cc,
	 output lc3b_mux_sel out
);

always_comb
begin
	if ((ir_9_11&cc) > 0)
		out = 1;
	else
		out = 0;
end

endmodule : fetch_logic
