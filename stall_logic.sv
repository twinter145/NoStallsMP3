import lc3b_types::*;
/*
module stall_logic
(
	 input clk,
	 input logic load_register,
    input logic mem_resp_a,
	 input logic mem_resp_b,
	 input logic write,
	 input logic read,
	 input lc3b_opcode opcode, //from mem
    output logic memory_stall,
	 output logic mem_addr_mux_sel,
	 output logic load_address_reg //maybe need? try using load_register for now
);
logic sel;

//always_comb
always_ff @(posedge clk)
begin
	//sel = 0;
	if(opcode == op_ldi)
	begin
		for(int i=0; i<1; i++)
		begin
			if(i==0)
			begin
				load_address_reg = 1;
				memory_stall = 1;
				sel = 0;
			end
			else if(i==1 && mem_resp_b == 1)
			begin
				load_address_reg = 1;
				memory_stall = 0;
				sel = 1;
			end
		end	
	end
	else
			//memory_stall = mem_control_sig.write_memory + mem_control_sig.read_memory;
			//sel = 0;
			memory_stall = write + read;
end

assign mem_addr_mux_sel = sel;

endmodule : stall_logic
*/

module stall_logic
(
	 input clk,
	 //input lc3b_word mem_address_in,
	 //input lc3b_word mem_rdata,
	 input logic load_register,
    input logic mem_resp_a,
	 input logic mem_resp_b,
	 input logic write,
	 input logic read,
	 input lc3b_opcode opcode, //from mem
    //output logic memory_stall,
	 output logic ldi_sig,
	 output logic mem_addr_mux_sel
	 //output logic load_address_reg, //maybe need? try using load_register for now
	 //output lc3b_word mem_address
);
//logic ldi_sig;

enum int unsigned {
	not_ldi,
	ldi1,
	ldi2
} state, next_state;

always_comb
begin : state_actions
	/* Default assignments */
	//memory_stall = write + read;
	//mem_address = mem_address_in;
	ldi_sig = 0; //0 if not ldi, 1 if ldi
	mem_addr_mux_sel = 0;
	
   /* Actions for each state */
	case(state)
	not_ldi: begin	
		//take all defaults
		//if(opcode == op_ldi)
			//ldi_sig = 1;
		//else
			//ldi_sig = 0;
	end
	
	ldi1: begin
		//memory_stall = 0;
		ldi_sig = 1;
		mem_addr_mux_sel = 1;
		//mem_address = mem_address_in;
	end
	/*
	ldi2: begin
		//memory_stall = 0;
		//ldi_sig = 1;
		mem_addr_mux_sel = 1;
		//mem_address = mem_rdata;
	end
	*/
	default: /* Do nothing */;
	endcase
end

always_comb
begin : next_state_logic
	/* Next state information and conditions (if any) for transitioning between states */
	case(state)
		not_ldi: begin
			if((opcode == op_ldi) && (mem_resp_b==1))
				next_state <= ldi1;
			else
				next_state <= not_ldi;
		end	
		
		ldi1: begin
			if(mem_resp_b == 1)
				next_state <= not_ldi;
			else
				next_state <= ldi1;
		end
		/*
		ldi2: begin
			//if(mem_resp_b == 1)
				next_state <= not_ldi;
			//else
			//	next_state <= ldi2;
		end
		*/
	default: next_state = not_ldi;
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
	 state <= next_state;
end

endmodule : stall_logic