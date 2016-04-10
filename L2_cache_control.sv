import lc3b_types::*;

module L2_cache_control
(
	input clk,

	/* Physical Memory Signals */
	input pmem_resp,
	output logic pmem_read,
	output logic pmem_write,

	/* CPU Memory Signals */
	output logic L2_resp,
	input L2_read,
	input L2_write,
	
	output logic [2:0] write_sel,
	output logic write,
	output logic lru_write,
	output logic [6:0] lru_data_in,
	output lc3b_byte valid_in,
	output lc3b_byte dirty_in,
	output logic [2:0] waydataselect_alt,
	output logic waydatacontrol,
	output logic highaddrmux_sel,
	output logic data_input_select,
	
	input hit,
	input [6:0] lru_data_out,
	input [2:0] waydatamux_sel,
	input lc3b_byte dirty_out
);

logic cycle_count;

enum int unsigned {
   /* List of states */
	idle_hit,
	save_dirty_data,
	read_mem
} state, next_state;

always_comb
begin : state_actions
	/* Default output assignments */
	pmem_read = 1'b0;
	pmem_write = 1'b0;
	L2_resp = 1'b0;
	write_sel = 3'b0;
	write = 1'b0;
	lru_write = 1'b0;
	lru_data_in = lru_data_out;
	valid_in = 8'hff;
	dirty_in = 8'b0;
	waydataselect_alt = 3'b0;
	waydatacontrol = 1'b0;
	highaddrmux_sel = 1'b0;
	data_input_select = 1'b0;
	
    /* Actions for each state */
	case(state)
		idle_hit: begin
			if((L2_read == 1'b1) || (L2_write == 1'b1)) begin
				if(hit == 1'b1) begin
					if(cycle_count == 1'b1) begin
						L2_resp = 1;
					end
					case(waydatamux_sel)
						3'h0: begin
							lru_data_in[0] = 1;
							lru_data_in[2] = 1;
							lru_data_in[6] = 1;
						end

						3'h1: begin
							lru_data_in[0] = 1;
							lru_data_in[2] = 1;
							lru_data_in[6] = 0;
						end
						
						3'h2: begin
							lru_data_in[0] = 1;
							lru_data_in[2] = 0;
							lru_data_in[5] = 1;
						end
						
						3'h3: begin
							lru_data_in[0] = 1;
							lru_data_in[2] = 0;
							lru_data_in[5] = 0;
						end
						
						3'h4: begin
							lru_data_in[0] = 0;
							lru_data_in[1] = 1;
							lru_data_in[4] = 1;
						end
						
						3'h5: begin
							lru_data_in[0] = 0;
							lru_data_in[1] = 1;
							lru_data_in[4] = 0;
						end
						
						3'h6: begin
							lru_data_in[0] = 0;
							lru_data_in[1] = 0;
							lru_data_in[3] = 1;
						end
						
						3'h7: begin
							lru_data_in[0] = 0;
							lru_data_in[1] = 0;
							lru_data_in[3] = 0;
						end
					endcase
					lru_write = 1;
					if(L2_write == 1'b1) begin
						write = 1;
						case(waydatamux_sel)
							3'h0: begin
								write_sel = 0;
								dirty_in[0] = 1;
							end
							
							3'h1: begin
								write_sel = 1;
								dirty_in[1] = 1;
							end
							
							3'h2: begin
								write_sel = 2;
								dirty_in[2] = 1;
							end
							
							3'h3: begin
								write_sel = 3;
								dirty_in[3] = 1;
							end
							
							3'h4: begin
								write_sel = 4;
								dirty_in[4] = 1;
							end
							
							3'h5: begin
								write_sel = 5;
								dirty_in[5] = 1;
							end
							
							3'h6: begin
								write_sel = 6;
								dirty_in[6] = 1;
							end
							
							3'h7: begin
								write_sel = 7;
								dirty_in[7] = 1;
							end
						endcase
					end
				end
				else
					L2_resp = 0;
			end
		end
		
		save_dirty_data: begin
			waydatacontrol = 1;
			if(lru_data_out[0] == 1'b0) begin
				if(lru_data_out[2] == 1'b0) begin
					if(lru_data_out[6] == 1'b0)
						waydataselect_alt = 0;
					else
						waydataselect_alt = 1;
				end
				else if(lru_data_out[5] == 1'b0)
					waydataselect_alt = 2;
				else
					waydataselect_alt = 3;
			end
			else if(lru_data_out[1] == 1'b0) begin
				if(lru_data_out[4] == 1'b0)
					waydataselect_alt = 4;
				else
					waydataselect_alt = 5;
			end
			else if(lru_data_out[3] == 1'b0)
				waydataselect_alt = 6;
			else
				waydataselect_alt = 7;

			highaddrmux_sel = 1;
			pmem_write = 1;
		end
		
		read_mem: begin
			write = 1;
			pmem_read = 1;
			data_input_select = 1;
			if(lru_data_out[0] == 1'b0) begin
				if(lru_data_out[2] == 1'b0) begin
					if(lru_data_out[6] == 1'b0)
						write_sel = 0;
					else
						write_sel = 1;
				end else begin
					if(lru_data_out[5] == 1'b0)
						write_sel = 2;
					else
						write_sel = 3;
				end
			end else begin
				if(lru_data_out[1] == 1'b0) begin
					if(lru_data_out[4] == 1'b0)
						write_sel = 4;
					else
						write_sel = 5;
				end else begin
					if(lru_data_out[3] == 1'b0)
						write_sel = 6;
					else
						write_sel = 7;
				end
			end
		end
		default: /* Do nothing */;
	endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
	next_state = idle_hit;

	case(state)
		idle_hit: begin
			if((L2_read == 1'b0) && (L2_write == 1'b0))
				next_state = idle_hit;
			else if(hit == 1'b1)
				next_state = idle_hit;
			else if(lru_data_out[0] == 1'b0) begin
				if(lru_data_out[2] == 1'b0) begin
					if(lru_data_out[6] == 1'b0) begin
						if(dirty_out[0] == 1'b1)
							next_state = save_dirty_data;
						else
							next_state = read_mem;
					end else begin
						if(dirty_out[1] == 1'b1)
							next_state = save_dirty_data;
						else
							next_state = read_mem;
					end
				end else begin
					if(lru_data_out[5] == 1'b0) begin
						if(dirty_out[2] == 1'b1)
							next_state = save_dirty_data;
						else
							next_state = read_mem;
					end else begin
						if(dirty_out[3] == 1'b1)
							next_state = save_dirty_data;
						else
							next_state = read_mem;
					end
				end
			end else begin
				if(lru_data_out[1] == 1'b0) begin
					if(lru_data_out[4] == 1'b0) begin
						if(dirty_out[4] == 1'b1)
							next_state = save_dirty_data;
						else
							next_state = read_mem;
					end else begin
						if(dirty_out[5] == 1'b1)
							next_state = save_dirty_data;
						else
							next_state = read_mem;
					end
				end else begin
					if(lru_data_out[3] == 1'b0) begin
						if(dirty_out[6] == 1'b1)
							next_state = save_dirty_data;
						else
							next_state = read_mem;
					end else begin
						if(dirty_out[7] == 1'b1)
							next_state = save_dirty_data;
						else
							next_state = read_mem;
					end
				end
			end
		end
		
		save_dirty_data: begin
			if(pmem_resp == 1'b0)
				next_state = save_dirty_data;
			else
				next_state = read_mem;
		end
		
		read_mem: begin
			if(pmem_resp == 1'b0)
				next_state = read_mem;
			else if(cycle_count == 1'b0)
				next_state = idle_hit;
		end
		
		default: begin
			next_state = idle_hit;
		end
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
	 state <= next_state;
end

always_ff @(posedge clk)
begin
	if((state == idle_hit) && ((L2_read == 1'b1) || (L2_write == 1'b1)) && (hit == 1'b1) && (cycle_count == 0))
		cycle_count = 1;
	else if((state == idle_hit) && (cycle_count == 1))
		cycle_count = 0;
	else if((state == read_mem) && (pmem_resp == 1'b1) && (cycle_count == 0))
		cycle_count = 1;
	else if((state == read_mem) && (cycle_count == 1))
		cycle_count = 0;
	else
		cycle_count = 0;
end

endmodule : L2_cache_control