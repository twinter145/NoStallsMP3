package lc3b_types;

typedef logic [15:0] lc3b_word;
typedef logic  [7:0] lc3b_byte;

typedef logic [10:0] lc3b_offset11;
typedef logic  [8:0] lc3b_offset9;
typedef logic  [5:0] lc3b_offset6;
typedef logic [7:0] lc3b_trapvect8;
typedef logic  [4:0] lc3b_imm5;
typedef logic [3:0] lc3b_imm4;

typedef logic  [2:0] lc3b_reg;
typedef logic  [2:0] lc3b_nzp;
typedef logic  [1:0] lc3b_mem_wmask;
typedef logic [1:0] lc3b_mux_sel;
typedef logic [2:0] lc3b_mux8_sel;

typedef logic [127:0] lc3b_line;
typedef logic [255:0] lc3b_d_line;
typedef logic [8:0] lc3b_c_tag;
typedef logic [10:0] lc3b_L2_tag;
typedef logic [2:0] lc3b_c_index;
typedef logic [2:0] lc3b_c_offset;

typedef enum bit [3:0] {
    op_add  = 4'b0001,
    op_and  = 4'b0101,
    op_br   = 4'b0000,
    op_jmp  = 4'b1100,   /* also RET */
    op_jsr  = 4'b0100,   /* also JSRR */
    op_ldb  = 4'b0010,
    op_ldi  = 4'b1010,
    op_ldr  = 4'b0110,
    op_lea  = 4'b1110,
    op_not  = 4'b1001,
    op_rti  = 4'b1000,
    op_shf  = 4'b1101,
    op_stb  = 4'b0011,
    op_sti  = 4'b1011,
    op_str  = 4'b0111,
    op_trap = 4'b1111
} lc3b_opcode;

typedef enum bit [3:0] {
    alu_add,
    alu_and,
    alu_not,
    alu_pass,
    alu_sll,
    alu_srl,
    alu_sra
} lc3b_aluop;

typedef struct packed {
	lc3b_opcode opcode;
	lc3b_aluop aluop;
	//register load
	logic load_cc;
	logic load_regfile;
	logic load_pc;
	//mux select
	lc3b_mux_sel wb_mux_sel;
	logic ldb_mux_sel;
	lc3b_mux_sel pc_mux_sel;
	logic instrsr1_mux_sel;
	lc3b_mux_sel offset_mux_sel;
	logic dest_mux_sel;
	lc3b_mux_sel address_mux_sel;
	logic sr2_mux_sel;
	lc3b_mux_sel immsr2_mux_sel;
	logic read_memory;
	logic write_memory;
	logic [1:0] memory_wmask;
	logic alua_mux_sel;
	lc3b_word ir;
} lc3b_control;

endpackage : lc3b_types
