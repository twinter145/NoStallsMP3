import lc3b_types::*;


module stall_logic
(
	 input clk,
	 input logic load_register,
    input logic mem_resp_a,
	 input logic mem_resp_b,
	 input logic write,
	 input logic read,
	 input lc3b_opcode opcode,
	// output logic ldi_sig,
	 output logic mem_addr_mux_sel,
	 output logic toggle,
	 output logic toggle_ldi,
	 output logic ldi_mux_sel
);
//logic ldi_sig;

enum int unsigned {
	not_stuff,
	ldi,
	sti,
	cont
} state, next_state;

always_comb
begin : state_actions
	/* Default assignments */
	//ldi_sig = 0; 
	mem_addr_mux_sel = 0;
	toggle = 0;
	toggle_ldi = 0;
	ldi_mux_sel = 0;
	
   /* Actions for each state */
	case(state)
	not_stuff: begin	
		//stuff
	end
	
	ldi: begin
		//ldi_sig = 1;
		mem_addr_mux_sel = 1;
	end

	sti: begin
		//ldi_sig = 1;
		mem_addr_mux_sel = 1;
		toggle = 1;
	end
	
	cont: begin
		toggle_ldi = 1;
		ldi_mux_sel = 1;
	end
	
	default: /* Do nothing */;
	endcase
end

always_comb
begin : next_state_logic
	/* Next state information and conditions (if any) for transitioning between states */
	case(state)
		not_stuff: begin
			if((opcode == op_ldi) && (mem_resp_b == 1))
				next_state <= ldi;
			else if((opcode == op_sti) && (mem_resp_b == 1))
				next_state <= sti;
			else
				next_state <= not_stuff;
		end	
		
		ldi: begin
			if(mem_resp_b == 1)
				next_state <= cont;
			else
				next_state <= ldi;
		end
	
		sti: begin
			if(mem_resp_b == 1)
				next_state <= cont;
			else
				next_state <= sti;
		end
		
		cont: begin
			next_state <= not_stuff;
		end
		
	default: next_state = not_stuff;
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
	 state <= next_state;
end

endmodule : stall_logic