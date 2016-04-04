import lc3b_types::*;

module control_rom
(
	/*inputs*/
	input lc3b_opcode opcode,
	input logic ir4,
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
	ctrl.address_mux_sel = 2'b01;
	ctrl.sr2_mux_sel = 0;
	ctrl.immsr2_mux_sel = 2'b01;
	ctrl.load_regfile = 0;
	ctrl.read_memory = 0;
	ctrl.write_memory = 0;
	ctrl.ldb_mux_sel = 0;
	ctrl.memory_wmask = 3;
	ctrl.alua_mux_sel = 0;
	case(ctrl.opcode)
		op_add: begin//
			if(ir5)
				ctrl.immsr2_mux_sel = 2'b01;
			else
				ctrl.immsr2_mux_sel = 2'b00;
			ctrl.aluop = alu_add;
			ctrl.sr2_mux_sel = 0;
		
			ctrl.wb_mux_sel = 3;
			ctrl.load_regfile = 1;
			ctrl.load_cc = 1;
		end
		
		op_and: begin//
			if(ir5)
				ctrl.immsr2_mux_sel = 2'b01;
			else
				ctrl.immsr2_mux_sel = 2'b00;
			ctrl.aluop = alu_and;
			ctrl.sr2_mux_sel = 0;
			ctrl.wb_mux_sel = 3;//alu_out
			ctrl.load_regfile = 1;
			ctrl.load_cc = 1;
		end
		
		op_not: begin//
			ctrl.aluop = alu_not;
			ctrl.wb_mux_sel = 3;//alu_out
			ctrl.load_regfile = 1;
			ctrl.load_cc = 1;
		end
		
		op_br: begin//
			ctrl.wb_mux_sel = 0;//??
			ctrl.offset_mux_sel = 2;
			ctrl.address_mux_sel = 2'b01;////////////////////////////////
		end
		
		op_ldr: begin//
			ctrl.wb_mux_sel = 1;//wb_rdata
			ctrl.read_memory = 1;
			ctrl.load_regfile = 1;
			ctrl.offset_mux_sel = 1;
			//ctrl.address_mux_sel = 1;
			ctrl.instrsr1_mux_sel = 1;
			ctrl.load_cc = 1;
		end
		
		op_str: begin//
			/*
			ctrl.wb_mux_sel = 0;//??
			ctrl.write_memory = 1;
			ctrl.offset_mux_sel = 1;*/
			
			ctrl.wb_mux_sel = 0;//??
			ctrl.write_memory = 1;
			ctrl.offset_mux_sel = 1;
			ctrl.instrsr1_mux_sel = 1;
			ctrl.sr2_mux_sel = 1;
			ctrl.immsr2_mux_sel = 0;
			ctrl.alua_mux_sel = 1;
			ctrl.aluop = alu_pass;
		end
		
		op_jmp: begin
			ctrl.aluop = alu_pass;
			ctrl.wb_mux_sel = 2'b11;
		end
		
		op_jsr: begin
			ctrl.wb_mux_sel = 2;//select incremented PC (for R7)
			ctrl.address_mux_sel = 1;
			ctrl.load_regfile = 1;
			ctrl.dest_mux_sel = 1;
			//ctrl.load_pc = 1;
			if (ir11 == 1) begin//select PC + offset11
				ctrl.instrsr1_mux_sel = 0;
				ctrl.offset_mux_sel = 3;
			end
			else begin//select base register
				ctrl.instrsr1_mux_sel = 1;
				ctrl.offset_mux_sel = 0;
			end
		end
		
		op_ldb: begin
			ctrl.immsr2_mux_sel = 2'b11;
			ctrl.aluop = alu_add;
			ctrl.ldb_mux_sel = 1;
			ctrl.address_mux_sel = 2'b10;
			ctrl.load_regfile = 1;
			ctrl.load_cc = 1;
			ctrl.wb_mux_sel = 2'b01;
			//wbmux??
		end
		
		op_ldi: begin
		end
		
		op_lea: begin
			ctrl.offset_mux_sel = 2;
			ctrl.instrsr1_mux_sel = 0;
			ctrl.address_mux_sel = 1;
			ctrl.wb_mux_sel = 0;
			ctrl.load_regfile = 1;
			ctrl.load_cc = 1;
		end
		
		op_rti: begin
		end
		
		op_shf: begin
			if(ir4 == 0)
				ctrl.aluop = alu_sll;
			else
				if(ir5 == 0)
					ctrl.aluop = alu_srl;
				else	
					ctrl.aluop = alu_sra;
			ctrl.immsr2_mux_sel = 2'b10;		
			ctrl.load_regfile = 1;
			ctrl.load_cc = 1;
			ctrl.wb_mux_sel = 2'b11;
		end
		
		op_stb: begin
			ctrl.wb_mux_sel = 0;//??
			ctrl.write_memory = 1;
			ctrl.memory_wmask = 1;
			ctrl.offset_mux_sel = 1;
			ctrl.instrsr1_mux_sel = 1;
			ctrl.sr2_mux_sel = 1;
			ctrl.immsr2_mux_sel = 0;
		end
		
		op_sti: begin
		end
		
		op_trap: begin
			ctrl.dest_mux_sel = 1;
			ctrl.load_regfile = 1;
			ctrl.wb_mux_sel = 2'b10;
			ctrl.address_mux_sel = 2'b00;
		end
		 
		default: begin
			
		end
	endcase
end

assign out = ctrl;

endmodule : control_rom
