import lc3b_types::*;

module register_scoreboard
(
    input clk,
    input logic write0, write1, mem_miss_a,
    input lc3b_reg index0, index1,
    output logic [7:0] dataout
);

logic [7:0] data;

/* Initialize array with all 1s */
initial
begin
    for (int i = 0; i < 8; i++)
    begin
        data[i] = 1'b1;
    end
end

always_ff @(posedge clk)
begin
	if (write0 == 1 && mem_miss_a == 0)
		data[index0] = 1'b0;

	if (write1 == 1)
		data[index1] = 1'b1;
end

assign dataout = data;

endmodule : register_scoreboard