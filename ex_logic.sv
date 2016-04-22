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
	output lc3b_word lc3x_mux_out,
	output logic ex_stall
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
lc3b_word divider_out;
logic [1:0] mult_stall_count;
logic [3:0] div_stall_count;
lc3b_mux_sel lc3x_mux_sel;
logic mult_clk_en;
logic div_clk_en;

always_comb
begin
	if((ex_ir[5:3] == 3'b000) && (ex_control_sig.mult_div == 1))
		mult_clk_en = 1;
	else
		mult_clk_en = 0;
	if((ex_ir[5:3] == 3'b001) && (ex_control_sig.mult_div == 1))
		div_clk_en = 1;
	else
		div_clk_en = 0;
end

always_ff @ (posedge clk)
begin
	if(mult_stall_count == 1)
		mult_stall_count = 2;
	else if(mult_stall_count == 2)
		mult_stall_count = 3;
	else if(mult_stall_count == 3)
		mult_stall_count = 0;
	else if((ex_control_sig.mult_div == 1) && (ex_ir[5:3] == 3'b000))
		mult_stall_count = 1;
	else
		mult_stall_count = 0;
end

always_ff @ (posedge clk)
begin
	if(div_stall_count == 1)
		div_stall_count = 2;
	else if(div_stall_count == 2)
		div_stall_count = 3;
	else if(div_stall_count == 3)
		div_stall_count = 4;
	else if(div_stall_count == 4)
		div_stall_count = 5;
	else if(div_stall_count == 5)
		div_stall_count = 6;
	else if(div_stall_count == 6)
		div_stall_count = 7;
	else if(div_stall_count == 7)
		div_stall_count = 0;
	else if(div_stall_count == 8)
		div_stall_count = 9;
	else if(div_stall_count == 9)
		div_stall_count = 10;
	else if(div_stall_count == 10)
		div_stall_count = 11;
	else if(div_stall_count == 11)
		div_stall_count = 12;
	else if(div_stall_count == 12)
		div_stall_count = 13;
	else if(div_stall_count == 13)
		div_stall_count = 14;
	else if(div_stall_count == 14)
		div_stall_count = 15;
	else if(div_stall_count == 15)
		div_stall_count = 0;
	else if((ex_control_sig.mult_div == 1) && (ex_ir[5:3] == 3'b001))
		div_stall_count = 1;
	else
		div_stall_count = 0;
end

always_comb
begin
	if((ex_control_sig.mult_div == 1) && (ex_ir[5:3] == 3'b000) && (mult_stall_count != 3))
		ex_stall = 1;
	else if((ex_control_sig.mult_div == 1) && (ex_ir[5:3] == 3'b001) && (div_stall_count != 7))
		ex_stall = 1;
	else
		ex_stall = 0;
end

assign ex_address = addressmux_out;

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

mux4 lc3x_mux
(
	.sel(ex_control_sig.lc3x_mux_sel),
	.a(ex_alu_out),
	.b(multiplier_out[15:0]),
	.c(divider_out),
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

multiplier lc3x_mult
(
	.clock(clk & mult_clk_en),
	.dataa(alua_mux_out),
	.datab(immsr2mux_out),
	.result(multiplier_out)
);

divider lc3x_div
(
	.clock(clk & div_clk_en),
	.denom(immsr2mux_out),
	.numer(alua_mux_out),
	.quotient(divider_out),
	.remain()
);

endmodule : ex_logic