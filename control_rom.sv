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
	ctrl.mem_wdata_b_sel = 0;
	ctrl.adj11sext6mux_sel = 0;
	
	ctrl.branch = 1'b0;
	ctrl.uses_sr1 = 1'b0;
	ctrl.uses_sr2 = 1'b0;
	ctrl.uses_dest = 1'b0;
	case(ctrl.opcode)
		op_add: begin//
			if(ir5)
				ctrl.immsr2_mux_sel = 2'b01;
			else begin
				ctrl.immsr2_mux_sel = 2'b00;
				
				ctrl.uses_sr2 = 1'b1;
			end
			ctrl.aluop = alu_add;
			ctrl.sr2_mux_sel = 0;
		
			ctrl.wb_mux_sel = 3;
			ctrl.load_regfile = 1;
			ctrl.load_cc = 1;
			
			ctrl.uses_dest = 1'b1;
			ctrl.uses_sr1 = 1'b1;
		end
		
		op_and: begin//
			if(ir5)
				ctrl.immsr2_mux_sel = 2'b01;
			else begin
				ctrl.immsr2_mux_sel = 2'b00;
				
				ctrl.uses_sr2 = 1'b1;
			end
			ctrl.aluop = alu_and;
			ctrl.sr2_mux_sel = 0;
			ctrl.wb_mux_sel = 3;//alu_out
			ctrl.load_regfile = 1;
			ctrl.load_cc = 1;
			
			ctrl.uses_dest = 1'b1;
			ctrl.uses_sr1 = 1'b1;
		end
		
		op_not: begin//
			ctrl.aluop = alu_not;
			ctrl.wb_mux_sel = 3;//alu_out
			ctrl.load_regfile = 1;
			ctrl.load_cc = 1;
			
			ctrl.uses_dest = 1'b1;
			ctrl.uses_sr1 = 1'b1;
		end
		
		op_br: begin//
			ctrl.wb_mux_sel = 0;//??
			ctrl.offset_mux_sel = 2;
			ctrl.address_mux_sel = 2'b01;////////////////////////////////
			
			ctrl.branch = 1'b1;
		end
		
		op_ldr: begin//
			ctrl.wb_mux_sel = 1;//wb_rdata
			ctrl.read_memory = 1;
			ctrl.load_regfile = 1;
			ctrl.offset_mux_sel = 1;
			//ctrl.address_mux_sel = 1;
			ctrl.instrsr1_mux_sel = 1;
			ctrl.load_cc = 1;
			
			ctrl.uses_dest = 1'b1;
			ctrl.uses_sr1 = 1'b1;
		end
		
		op_str: begin//
			ctrl.wb_mux_sel = 0;//??
			ctrl.write_memory = 1;
			ctrl.offset_mux_sel = 1;
			ctrl.instrsr1_mux_sel = 1;
			ctrl.sr2_mux_sel = 1;
			ctrl.immsr2_mux_sel = 0;
			ctrl.alua_mux_sel = 1;
			ctrl.aluop = alu_pass;
			
			//ctrl.uses_dest = 1'b1;
			//ctrl.uses_sr1 = 1'b1;
		end
		
		op_jmp: begin
			ctrl.aluop = alu_pass;
			ctrl.wb_mux_sel = 2'b11;
			
			ctrl.branch = 1'b1;
			ctrl.uses_sr1 = 1'b1;
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
				
				ctrl.uses_sr1 = 1'b1;
			end
			
			ctrl.branch = 1'b1;
		end
		
		op_ldb: begin
			ctrl.offset_mux_sel = 3;
			ctrl.instrsr1_mux_sel = 1;
			ctrl.ldb_mux_sel = 1;
			ctrl.read_memory = 1;
			ctrl.load_regfile = 1;
			ctrl.load_cc = 1;
			//ctrl.wb_mux_sel = 2'b01;
			ctrl.adj11sext6mux_sel = 1;
			//wbmux??
			
			ctrl.uses_dest = 1'b1;
			ctrl.uses_sr1 = 1'b1;
		end
		
		op_ldi: begin //should be same as ldr with add'l mux, b/c just doing ldr up to mem, then reloading data as address
			ctrl.wb_mux_sel = 1;//wb_rdata
			ctrl.read_memory = 1;
			ctrl.load_regfile = 1;
			ctrl.offset_mux_sel = 1;
			ctrl.instrsr1_mux_sel = 1;
			ctrl.load_cc = 1;

			ctrl.uses_dest = 1'b1;
			ctrl.uses_sr1 = 1'b1;
		end
		
		op_lea: begin
			ctrl.offset_mux_sel = 2;
			ctrl.instrsr1_mux_sel = 0;
			ctrl.address_mux_sel = 1;
			ctrl.wb_mux_sel = 0;
			ctrl.load_regfile = 1;
			ctrl.load_cc = 1;
			
			ctrl.uses_dest = 1'b1;
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
			
			ctrl.uses_dest = 1'b1;
			ctrl.uses_sr1 = 1'b1;
		end
		
		op_stb: begin
			ctrl.wb_mux_sel = 0;//??
			ctrl.write_memory = 1;
			ctrl.offset_mux_sel = 3;
			ctrl.instrsr1_mux_sel = 1;
			ctrl.sr2_mux_sel = 1;
			ctrl.mem_wdata_b_sel = 1;
			ctrl.alua_mux_sel = 1;
			ctrl.adj11sext6mux_sel = 1;
			
			//ctrl.uses_dest = 1'b1;
			//ctrl.uses_sr1 = 1'b1;
		end
		
		op_sti: begin
			ctrl.read_memory = 1;
			ctrl.offset_mux_sel = 1;
			ctrl.instrsr1_mux_sel = 1;
			ctrl.sr2_mux_sel = 1;
			ctrl.immsr2_mux_sel = 0;
			ctrl.alua_mux_sel = 1;
			ctrl.aluop = alu_pass;
			
			//ctrl.uses_dest = 1'b1;
			//ctrl.uses_sr1 = 1'b1;
		end
		
		op_trap: begin
			ctrl.dest_mux_sel = 1;
			ctrl.load_regfile = 1;
			ctrl.wb_mux_sel = 2'b10;
			ctrl.address_mux_sel = 2'b00;
			ctrl.read_memory = 1;
			
			ctrl.branch = 1'b1;
		end
		 
		default: begin
			
		end
	endcase
end

assign out = ctrl;

endmodule : control_rom
