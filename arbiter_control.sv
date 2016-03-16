import lc3b_types::*;

module arbiter_control
(
	input clk,
	
	input I_write,
	input I_read,
	
	input D_write,
	input D_read,
	
	input L2_resp,
	
	output logic I_resp_en,
	output logic D_resp_en,
	output logic cache_select
);

enum int unsigned {
   /* List of states */
	idle,
	D_cache_rw,
	I_cache_rw
} state, next_state;

always_comb
begin : state_actions
	/* Default output assignments */
	cache_select = 1'b0;
	I_resp_en = 1'b0;
	D_resp_en = 1'b0;
	
	case(state)
		idle: begin
		end
		
		D_cache_rw: begin
			D_resp_en = 1;
			cache_select = 1;
		end
		
		I_cache_rw: begin
			I_resp_en = 1;
			cache_select = 0;
		end
		
		default: /* Do nothing */;
	endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
	next_state = idle;

	case(state)
		idle: begin
			if((I_read == 1'b1) || (I_write == 1'b1))
				next_state = I_cache_rw;
			else if((D_read == 1'b1) || (D_write == 1'b1))
				next_state = D_cache_rw;
		end
		
		I_cache_rw: begin
			if(L2_resp == 1'b0)
				next_state = I_cache_rw;
			else if((D_read == 1'b1) || (D_write == 1'b1))
				next_state = D_cache_rw;
			else
				next_state = idle;
		end
		
		D_cache_rw: begin
			if(L2_resp == 1'b0)
				next_state = D_cache_rw;
			else if((I_read == 1'b1) || (I_write == 1'b1))
				next_state = I_cache_rw;
			else
				next_state = idle;
		end
		
		default:;
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
	 state <= next_state;
end
	
endmodule : arbiter_control