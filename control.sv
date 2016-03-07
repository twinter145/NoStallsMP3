import lc3b_types::*; /* Import types defined in lc3b_types.sv */

module control
(
	input clk,
	/* Datapath controls */
	input lc3b_opcode opcode,
	input lc3b_nzp branch_enable,
	output logic load_pc,
	output logic load_ir,
	output logic load_regfile,
	output logic load_mar,
	output logic load_mdr,
	output logic load_cc,
	output logic storemux_sel,
	output lc3b_mux_sel marmux_sel,
	output lc3b_mux_sel mdrmux_sel,
	output lc3b_aluop aluop,
	/* et cetera */
	/* Memory signals */
	input logic mem_resp,
	output logic mem_read,
	output logic mem_write,
	output lc3b_mem_wmask mem_byte_enable,
	/*more*/
	input logic ir5,
	input logic ir6,
	input logic ir11,
	output lc3b_mux8_sel alumux_sel,
	output lc3b_mux_sel pcmux_sel,
	output lc3b_mux8_sel regfilemux_sel,
	output logic destmux_sel,
	output lc3b_mux_sel addr2mux_sel,
	input logic mar0
);

enum int unsigned {
	fetch1,
	fetch2,
	fetch3,
	decode,
	s_add,
	s_and,
	s_not,
	s_br,
	br_taken,
	calc_addr,
	lea,
	jmp,
	ldr1,
	ldr2,
	str1,
	str2,
	//new after mp3 checkpoint
	jsr_start,
	jsr_end,
	jsrr_end,
	calc_addr_byte,
	ldb1,
	ldb2,
	stb1,
	stb2,
	shf,
	trap1,
	trap2,
	trap3,
	calc_addr_indir1,
	calc_addr_indir2,
	calc_addr_indir3
} state, next_state;

always_comb
begin : state_actions
	/* Default assignments */
	load_pc = 1'b0;
	load_ir = 1'b0;
	load_regfile = 1'b0;
	load_mar = 1'b0;
	load_mdr = 1'b0;
	load_cc = 1'b0;
	pcmux_sel = 2'b00;
	storemux_sel = 1'b0;
	alumux_sel = 3'b000;
	regfilemux_sel = 3'b000;
	marmux_sel = 2'b00;
	mdrmux_sel = 2'b00;
	aluop = alu_add;
	mem_read = 1'b0;
	mem_write = 1'b0;
	mem_byte_enable = 2'b11;
	destmux_sel = 1'b0;
	addr2mux_sel = 2'b00;
	
   /* Actions for each state */
	case(state)
		fetch1: begin
			/* MAR <= PC */
			marmux_sel = 01;
			load_mar = 1;
			/* PC <= PC + 2 */
			pcmux_sel = 00;
			load_pc = 1;
		end
		fetch2: begin
			/* Read memory */
			mem_read = 1;
			mdrmux_sel = 01;
			load_mdr = 1;
		end
		fetch3: begin
			/* Load IR */
			load_ir = 1;
		end
		decode: /* Do nothing */;
		s_add: begin
			/* DR <= SRA + SRB */
			aluop = alu_add;
			alumux_sel = {1'b0,ir5,1'b0};
			load_regfile = 1;
			regfilemux_sel = 000;
			load_cc = 1;
		end
		s_and: begin
			aluop = alu_and;
			alumux_sel = {1'b0,ir5,1'b0};
			load_regfile = 1;
			load_cc = 1;
		end
		s_not: begin
			aluop = alu_not;
			load_regfile = 1;
			load_cc = 1;
		end
		br_taken: begin
			pcmux_sel = 01;
			load_pc = 1;
		end
		calc_addr: begin
			alumux_sel = 001;
			aluop = alu_add;
			load_mar = 1;
		end
		ldr1: begin
			mdrmux_sel = 01;
			load_mdr = 1;
			mem_read = 1;
		end
		ldr2: begin
			regfilemux_sel = 001;
			load_regfile = 1;
			load_cc = 1;
		end
		str1: begin
			storemux_sel = 1;
			aluop = alu_pass;
			load_mdr = 1;
		end
		str2: begin
			mem_write = 1;
		end
		lea: begin
			regfilemux_sel = 010;
			load_regfile = 1;
			load_cc = 1;
		end
		jmp: begin
			pcmux_sel = 10;
			aluop = alu_pass;
			load_pc = 1;
		end
		//
		shf: begin
			if (ir5 == 0) aluop = alu_sll;
			else begin
				if (ir6 == 0) aluop = alu_srl;
				else aluop = alu_sra;
			end
			alumux_sel = 011;
			load_regfile = 1;
			regfilemux_sel = 000;
			load_cc = 1;
		end
		jsr_start: begin
			//R7 <- PC
			destmux_sel = 1;
			regfilemux_sel = 011;
			load_regfile = 1;
		end
		jsrr_end: begin
			//PC = BaseR (SR1)
			aluop = alu_pass;
			pcmux_sel = 10;
			load_pc = 1;
			storemux_sel = 0;
		end
		jsr_end: begin
			addr2mux_sel = 01;
			pcmux_sel = 01;
			load_pc = 1;
		end
		trap1: begin
			//MAR <- ZEXT(trapvect8)<<1
			load_mar = 1;
			marmux_sel = 10;
		end
		trap2: begin
			//MDR <- M[MAR]
			mdrmux_sel = 01;
			load_mdr = 1;
			mem_read = 1;
			//R7 <- PC
			destmux_sel = 1;
			regfilemux_sel = 011;
			load_regfile = 1;
		end
		trap3: begin
			//PC <- MDR
			pcmux_sel = 11;
			load_pc = 1;
		end
		calc_addr_byte: begin
			alumux_sel = 100;
			aluop = alu_add;
			load_mar = 1;
		end
		ldb1: begin
			mdrmux_sel = 01;
			load_mdr = 1;
			mem_read = 1;
		end
		ldb2: begin
			regfilemux_sel = {2'b10, mar0};
			load_regfile = 1;
			load_cc = 1;
		end
		stb1: begin
			storemux_sel = 1;
			aluop = alu_pass;
			mdrmux_sel = {1'b1, mar0};
			load_mdr = 1;
			//mem_byte_enable = {mar0,(~mar0)};
		end
		stb2: begin
			mem_write = 1;
			mem_byte_enable = {mar0,(~mar0)};
		end
		calc_addr_indir1: begin
			//MAR <- PC+off6
			alumux_sel = 001;
			aluop = alu_add;
			load_mar = 1;
		end
		calc_addr_indir2: begin
			//MDR = mem[MAR]
			mdrmux_sel = 01;
			load_mdr = 1;
			mem_read = 1;
		end
		calc_addr_indir3: begin
			//MAR <- MDR
			marmux_sel = 11;
			load_mar = 1;
		end
		default: /* Do nothing */;
	endcase
end

always_comb
begin : next_state_logic
	/* Next state information and conditions (if any) for transitioning between states */
	case(state)
		fetch1: next_state = fetch2;
		fetch2: begin
			if (mem_resp == 0) next_state = fetch2;
			else next_state = fetch3;
		end
		fetch3: next_state = decode;
		decode: case(opcode)
			op_add: next_state = s_add;
			op_and: next_state = s_and;
			op_not: next_state = s_not;
			op_br: next_state = s_br;
			op_ldr: next_state = calc_addr;
			op_str: next_state = calc_addr;
			op_lea: next_state = calc_addr;
			op_jmp: next_state = jmp;
			op_shf: next_state = shf;
			op_jsr: next_state = jsr_start;
			op_trap: next_state = trap1;
			op_ldb: next_state = calc_addr_byte;
			op_stb: next_state = calc_addr_byte;
			op_ldi: next_state = calc_addr_indir1;
			op_sti: next_state = calc_addr_indir1;
			default: next_state = fetch1;
		endcase
		calc_addr: case(opcode)
			op_ldr: next_state = ldr1;
			op_str: next_state = str1;
			op_lea: next_state = lea;
			default: next_state = fetch1;
		endcase
		ldr1: begin
			if (mem_resp == 0) next_state = ldr1;
			else next_state = ldr2;
		end
		ldr2: next_state = fetch1;
		str1: next_state = str2;
		str2: begin
			if (mem_resp == 0) next_state = str2;
			else next_state = fetch1;
		end
		s_br: begin
			if (branch_enable == 1) next_state = br_taken;
			else next_state = fetch1;
		end
		br_taken: next_state = fetch1;
		lea: next_state = fetch1;
		jmp: next_state = fetch1;
		jsr_start: begin
			if (ir11 == 0) next_state = jsrr_end;
			else next_state = jsr_end;
		end
		trap1: next_state = trap2;
		trap2: begin
			if (mem_resp == 0) next_state = trap2;
			else next_state = trap3;
		end
		calc_addr_byte: case(opcode)
			op_ldb: next_state = ldb1;
			op_stb: next_state = stb1;
			default: next_state = fetch1;
		endcase
		ldb1: begin
			if (mem_resp == 0) next_state = ldb1;
			else next_state = ldb2;
		end
		ldb2: next_state = fetch1;
		stb1: next_state = stb2;
		stb2: begin
			if (mem_resp == 0) next_state = stb2;
			else next_state = fetch1;
		end
		calc_addr_indir1: next_state = calc_addr_indir2;
		calc_addr_indir2: begin
			if (mem_resp == 0) next_state = calc_addr_indir2;
			else next_state = calc_addr_indir3;
		end
		calc_addr_indir3: case(opcode)
			op_ldi: next_state = ldr1;
			op_sti: next_state = str1;
			default: next_state = fetch1;
		endcase
		default: next_state = fetch1;
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
	 state <= next_state;
end

endmodule : control
