import lc3b_types::*;

module ex_logic
(
	input lc3b_control ex_control_signal,
	input lc3b_word ex_next_instruction,
	input lc3b_word ex_ir,
	input lc3b_word ex_sr1,
	input lc3b_word ex_sr2,
	
	output lc3b_word ex_address,
	output lc3b_word ex_alu_out
);

lc3b_word instrsr1mux_out;
lc3b_word offsetmux_out;
lc3b_word adj6_out;
lc3b_word adj9_out;
lc3b_word adj11_out;
lc3b_word offsetadder_out;
lc3b_word zext8_out;
lc3b_word addressmux_out;
lc3b_word sext5_out;

mux2 instrsr1mux
(
	.sel(), // from control word
	.a(ex_next_instruction),
	.b(ex_sr1),
	.f(instrsr1mux_out)
);

mux4 offsetmux
(
	.sel(), // from control word
	.a(16'b0),
	.b(adj6_out),
	.c(adj9_out),
	.d(adj11_out),
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

adder offsetadder
(
	.a(instrsr1mux_out),
	.b(offsetmux_out),
	.f(offsetadder_out)
);

zext zext8
(
	.in(ex_ir[7:0]),
	.out(zext8_out)
);

mux2 addressmux
(
	.sel(), // from control word
	.a(zext8_out),
	.b(offsetadder_out),
	.f(addressmux_out)
);

sext #(.width(5)) sext5
(
	.in(ex_ir[4:0]),
	.out(sext5_out)
);

mux2 immsr2mux
(
	.sel(), // from control word
	.a(ex_sr2),
	.b(sext5_out),
	.f(immsr2mux_out)
);

alu ALU
(
	.aluop(), // from control word
	.a(ex_sr1),
	.b(immsr2mux_out),
	.f(ex_alu_out)
);

endmodule : ex_logic