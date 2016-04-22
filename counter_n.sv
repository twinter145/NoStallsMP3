import lc3b_types::*;

module counter_n #(parameter width = 16)
(
    input clk,
    input logic increment, reset,
	 
    output logic [width-1:0] count
);

logic [width-1:0] data;
logic done;

initial
begin
	  data = 0;
	  done = 0;
end

always_ff @(posedge clk)
begin
	if (reset) begin
			data = 0;
	end else if (increment) begin
		if (~done) begin
			data += 1;
			done = 1;
		end
	end else begin
		done = 0;
	end
end

assign count = data;

endmodule : counter_n