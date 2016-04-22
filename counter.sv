import lc3b_types::*;

module counter #(parameter width = 16)
(
    input clk,
    input logic increment, reset,
	 
    output logic [width-1:0] count
);

logic [width-1:0] data;

initial
begin
	  data = 0;
end

always_ff @(posedge clk)
begin
	if (reset) begin
			data = 0;
	end else if (increment) begin
		data += 1;
	end
end

assign count = data;

endmodule : counter