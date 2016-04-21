import lc3b_types::*;

module ex_logic
(
	input clk,
	input lc3b_aluop aluop, //alu_op from control rom
	input lc3b_control ex_control_sig,
	input lc3b_word ex_next_instruction,
	input lc3b_word ex_ir,
	input lc3b_word ex_sr1,
	input lc3b_word ex_sr2,
	
	output lc3b_word ex_address,
	output lc3b_word lc3x_mux_out
);

lc3b_word ex_alu_out;
lc3b_word instrsr1mux_out;
lc3b_word immsr2mux_out;
lc3b_word offsetmux_out;
lc3b_word adj6_out;
lc3b_word adj9_out;
lc3b_word adj11_out;
lc3b_word offsetadder_out;
lc3b_word trap_out;
lc3b_word addressmux_out;
lc3b_word sext5_out;
lc3b_word sext6_out;
lc3b_word zext4_out;
lc3b_word alua_mux_out;
lc3b_word adj11sext6mux_out;
logic [31:0] multiplier_out;
logic mult_clk_en;
lc3b_mux_sel lc3x_mux_sel;

assign ex_address = addressmux_out;
always_comb
begin
	if(ex_control_sig.aluop == alu_mult || aluop == alu_mult)
		mult_clk_en = 1;
	else
		mult_clk_en = 0;
end

mux2 instrsr1mux
(
	.sel(ex_control_sig.instrsr1_mux_sel), // from control word
	.a(ex_next_instruction),
	.b(ex_sr1),
	.f(instrsr1mux_out)
);

mux4 offsetmux
(
	.sel(ex_control_sig.offset_mux_sel), // from control word
	.a(16'b0),
	.b(adj6_out),
	.c(adj9_out),
	.d(adj11sext6mux_out),
	.f(offsetmux_out)
);

adj #(.width(6)) adj6
(
	.in(ex_ir[5:0]),
	.out(adj6_out)
);

adj #(.width(9)) adj9
(
	.in(ex_ir[8:0]),
	.out(adj9_out)
);

adj #(.width(11)) adj11
(
	.in(ex_ir[10:0]),
	.out(adj11_out)
);

sext #(.width(6)) sext6
(
	.in(ex_ir[5:0]),
	.out(sext6_out)
);

mux2 #(.width(16)) adj11_sext6_mux
(
	.sel(ex_control_sig.adj11sext6mux_sel),
	.a(adj11_out),
	.b(sext6_out),
	.f(adj11sext6mux_out)
);

adder offsetadder
(
	.a(instrsr1mux_out),
	.b(offsetmux_out),
	.f(offsetadder_out)
);

trap #(.width(8))trap
(
	.in(ex_ir[7:0]),
	.out(trap_out)
);

mux4 addressmux
(
	.sel(ex_control_sig.address_mux_sel), // from control word
	.a(trap_out),
	.b(offsetadder_out),
	.c(lc3x_mux_out),
	.d(),
	.f(addressmux_out)
);

sext #(.width(5)) sext5
(
	.in(ex_ir[4:0]),
	.out(sext5_out)
);

zext #(.width(4)) zext4
(
	.in(ex_ir[3:0]),
	.out(zext4_out)
);

mux4 immsr2mux
(
	.sel(ex_control_sig.immsr2_mux_sel), // from control word
	.a(ex_sr2),
	.b(sext5_out),
	.c(zext4_out),
	.d(sext6_out),
	.f(immsr2mux_out)
);

mux2 alua_mux
(
	.sel(ex_control_sig.alua_mux_sel), // from control word
	.a(ex_sr1),
	.b(ex_sr2),
	.f(alua_mux_out)
);

mult3 multiplier
(
	.dataa(alua_mux_out),
	.datab(immsr2mux_out),
	.result(multiplier_out)
);	

mux4 lc3x_mux
(
	.sel(ex_control_sig.lc3x_mux_sel),
	.a(ex_alu_out),
	.b(multiplier_out[15:0]),
	.c(),
	.d(),
	.f(lc3x_mux_out)
);


alu ALU
(
	.aluop(ex_control_sig.aluop), // from control word
	.a(alua_mux_out),
	.b(immsr2mux_out),
	.f(ex_alu_out)
);

endmodule : ex_logic