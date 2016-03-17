import lc3b_types::*;

module D_cache_control
(
	input clk,
	
	/* Physical Memory Signals */
	input pmem_resp,
	output logic pmem_read,
	output logic pmem_write,

	/* CPU Memory Signals */
	output logic mem_resp,
	input mem_read,
	input mem_write,
	input lc3b_mem_wmask mem_byte_enable,
	
	input hit,
	input lru_out,
	input way0_dirty_out,
	input way1_dirty_out,
	input waydatamux_sel,
	
	output logic way0_write,
	output logic way1_write,
	output logic way0_dirty_data,
	output logic way1_dirty_data,
	output logic way0_valid_data,
	output logic way1_valid_data,
	output logic lru_data,
	output logic lru_write,
	output logic data_input_select,
	output logic highaddrmux_sel,
	output logic tagmux_sel,
	output logic waydatacontrol,
	output logic waydataselect_alt
);

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
	mem_resp = 1'b0;
	
	way0_write = 1'b0;
	way1_write = 1'b0;
	way0_dirty_data = 1'b0;
	way1_dirty_data = 1'b0;
	way0_valid_data = 1'b1;
	way1_valid_data = 1'b1;
	lru_data = 1'b0;
	lru_write = 1'b0;
	data_input_select = 1'b0;
	highaddrmux_sel = 1'b0;
	tagmux_sel = 1'b0;
	waydatacontrol = 1'b0;
	waydataselect_alt = 1'b0;
	
    /* Actions for each state */
	case(state)
		idle_hit: begin
			if(mem_read == 1'b1) begin
				if(hit == 1'b1) begin
					mem_resp = 1;
					lru_data = ~waydatamux_sel;
					lru_write = 1;
				end
				else
					mem_resp = 0;
			end
			else if(mem_write == 1'b1) begin
				if(hit == 1'b1) begin
					mem_resp = 1;
					lru_data = ~waydatamux_sel;
					lru_write = 1;
					if(waydatamux_sel == 0) begin
						way0_write = 1;
						way0_dirty_data = 1;
					end
					else begin
						way1_write = 1;
						way1_dirty_data = 1;
					end
				end
				else
					mem_resp = 0;
			end
		end
		
		save_dirty_data: begin
			waydatacontrol = 1;
			waydataselect_alt = lru_out;
			tagmux_sel = lru_out;
			highaddrmux_sel = 1;
			pmem_write = 1;
		end
		
		read_mem: begin
			if(lru_out == 1'b0)
				way0_write = 1;
			else
				way1_write = 1;
			data_input_select = 1;
			pmem_read = 1;
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
			if((mem_read == 1'b0) && (mem_write == 1'b0))
				next_state = idle_hit;
			else if(hit == 1'b1)
				next_state = idle_hit;
			else if(lru_out == 1'b0) begin
				if(way0_dirty_out == 1'b0)
					next_state = read_mem;
				else
					next_state = save_dirty_data;
			end
			else begin
				if(way1_dirty_out == 1'b0)
					next_state = read_mem;
				else
					next_state = save_dirty_data;
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
			else
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


endmodule : D_cache_control