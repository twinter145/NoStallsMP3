import lc3b_types::*;

module nzp_comparator
(
    input lc3b_nzp in, cc,
    output logic out
);

always_comb
begin
	 if ((in & cc) > 3'b0)
		out = 1'b1;
	 else
		out = 1'b0;
end

endmodule : nzp_comparator
