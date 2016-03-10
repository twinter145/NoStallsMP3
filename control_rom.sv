import lc3b_types::*;

module control_rom
(
	/*inputs*/
	input lc3b_opcode opcode,
	input logic ir5,
	input logic ir11,
	
	/*outputs*/
	output lc3b_word control_signal
);
lc3b_word data;

always_comb
begin
	data = 4'h0;
	case(opcode)
	    op_add: begin
		 end
		 
		 op_and: begin
		 end
		 
		 op_br: begin
		 end
		 
		 op_jmp: begin
		 end
		 
		 op_jsr: begin
		 end
    
		 op_ldb: begin
		 end
		 
		 op_ldi: begin
		 end
		 
		 op_ldr: begin
		 end
		 
		 op_lea: begin
		 end
		 
		 op_not: begin
		 end
		 
		 op_rti: begin
		 end
		 
		 op_shf: begin
		 end
		 
		 op_stb: begin
		 end
		 
		 op_sti: begin
		 end
		 
		 op_str: begin
		 end
		 
		 op_trap: begin
		 end
		 
	default: ;
	endcase
end

assign control_signal = data;

endmodule : control_rom
