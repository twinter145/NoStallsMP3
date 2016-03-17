import lc3b_types::*;

module control_rom
(
	/*inputs*/
	input lc3b_opcode opcode,
	input logic ir5,
	input logic ir11,
	
	/*outputs*/
	output lc3b_control out
);
lc3b_control ctrl;
assign ctrl.opcode = opcode;

always_comb
begin
	ctrl.aluop = alu_pass;
	//register load
	ctrl.load_cc = 0;
	ctrl.load_regfile = 0;
	ctrl.load_pc = 0;
	//mux select
	ctrl.wb_mux_sel = 0;
	ctrl.pc_mux_sel = 0;
	ctrl.instrsr1_mux_sel = 0;
	ctrl.offset_mux_sel = 0;
	ctrl.dest_mux_sel = 0;
	ctrl.address_mux_sel = 1;
	ctrl.sr2_mux_sel = 0;
	ctrl.immsr2_mux_sel = 1;
	ctrl.load_regfile = 0;
	ctrl.read_memory = 0;
	ctrl.write_memory = 0;
	case(ctrl.opcode)
		op_add: begin//
			ctrl.aluop = alu_add;
			ctrl.sr2_mux_sel = 0;
			ctrl.immsr2_mux_sel = ir5;
			ctrl.wb_mux_sel = 3;
			ctrl.load_regfile = 1;
			
		end
		
		op_and: begin//
			ctrl.aluop = alu_and;
			ctrl.sr2_mux_sel = 0;
			ctrl.immsr2_mux_sel = ir5;
			ctrl.wb_mux_sel = 3;//alu_out
			ctrl.load_regfile = 1;
		end
		
		op_not: begin//
			ctrl.aluop = alu_not;
			ctrl.wb_mux_sel = 3;//alu_out
			ctrl.load_regfile = 1;
		end
		
		op_br: begin//
			ctrl.wb_mux_sel = 0;//??
			ctrl.offset_mux_sel = 2;
		end
		
		op_ldr: begin//
			ctrl.wb_mux_sel = 1;//wb_rdata
			ctrl.read_memory = 1;
			ctrl.load_regfile = 1;
			ctrl.offset_mux_sel = 1;
			ctrl.instrsr1_mux_sel = 1;
		end
		
		op_str: begin//
			ctrl.wb_mux_sel = 0;//??
			ctrl.write_memory = 1;
			ctrl.offset_mux_sel = 1;
		end
		
		op_jmp: begin
		end
		
		op_jsr: begin
		end
		
		op_ldb: begin
		end
		
		op_ldi: begin
		end
		
		op_lea: begin
		end
		
		op_rti: begin
		end
		
		op_shf: begin
		end
		
		op_stb: begin
		end
		
		op_sti: begin
		end
		
		op_trap: begin
		end
		 
		default: begin
			
		end
	endcase
end

assign out = ctrl;

endmodule : control_rom
