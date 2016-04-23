import lc3b_types::*;

module register_scoreboard
(
    input clk,
    input logic uses_dest0, uses_dest1, mem_miss_a, mem_miss_b, br_taken, br_taken_count, load_wb, load_de,
	 input logic [1:0] br_stall_count,
    input lc3b_reg index0, index1,
    output logic [7:0] dataout
);

logic [7:0] data;
logic [1:0] count_data [0:7];
logic write0;
logic write1;

/* Initialize array with all 1s */
initial
begin
    for (int i = 0; i < 8; i++)
    begin
        data[i] = 1'b1;
		  count_data[i] = 0;
    end
end

always_comb
begin
	if(uses_dest0 == 1 && mem_miss_a == 0 && mem_miss_b == 0 && br_stall_count == 0 && br_taken == 0 && br_taken_count == 0 && load_de == 1)
		write0 = 1;
	else
		write0 = 0;
end

always_comb
begin
	if(uses_dest1 == 1 && load_wb == 1)
		write1 = 1;
	else
		write1 = 0;
end

//cycling between 4 different wrongs, any change to how the scoreboard writes fuuuuuccckkkss everything up worse, definitely need SOME sort of count to keep track of when
//it's ok for a register to be available....continue here
always_ff @(posedge clk)
begin
	if((write0 == 1) && (write1 == 1) && (index0 == index1))
		data[index0] = 0;
	else
	begin
		if (write0 == 1)
		begin
			data[index0] = 1'b0;
			count_data[index0]++;
		end
		
		if (write1 == 1)
		begin
			if(count_data[index1] == 1)
			begin
				data[index1] = 1'b1;
				count_data[index1] = 0;
			end
			else
				count_data[index1]--;
		end
	end
end

assign dataout = data;

endmodule : register_scoreboard