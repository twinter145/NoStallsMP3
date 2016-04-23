module counter_nn #(parameter width = 16)
(
    input clk,
    input logic increment, reset,
	 
    output logic [width-1:0] count
);

logic [width-1:0] data;
logic [1:0] done;

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
		if (done == 0) begin
			done = 1;
		end else if (done == 1) begin
			done = 2;
		end else if (done == 2) begin
			data++;
			done = 3;
		end
	end else begin
		done = 0;
	end
end

assign count = data;

endmodule : counter_nn