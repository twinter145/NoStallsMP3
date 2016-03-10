import lc3b_types::*;

module cc
(
	 input clk,
    input lc3b_nzp in,
	 input logic load_cc,
    output lc3b_nzp out
);

always_ff @(posedge clk)
begin
	 if (load_cc)
	 begin
		out = in;
	 end
end

endmodule : cc
