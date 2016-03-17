import lc3b_types::*;

module L2_cache_control
(
	input clk
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
	
    /* Actions for each state */
	case(state)
		idle_hit: begin
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


endmodule : L2_cache_control