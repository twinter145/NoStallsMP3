import lc3b_types::*;

module ir
(
    input clk,
    input load,
    input lc3b_word in,
	 output lc3b_word out,
    output lc3b_opcode opcode,
    output lc3b_reg dest, src1, src2,
    //output lc3b_offset6 offset6,
    //output lc3b_offset9 offset9,
	 //output lc3b_offset11 offset11,
	 //output lc3b_imm5 imm5,
	 //output lc3b_imm4 imm4,
	 //output lc3b_trapvect8 trapvect8,
	 output logic ir5,
	 //output logic ir6,
	 output logic ir11
);

lc3b_word data;

always_ff @(posedge clk)
begin
    if (load == 1)
    begin
        data = in;
    end
end

always_comb
begin
	opcode = lc3b_opcode'(data[15:12]);

	dest = data[11:9];
	src1 = data[8:6];
	src2 = data[2:0];
	
	ir5 = data[5];
	//ir6 = data[6];
	ir11 = data[11];
	/*
	imm5 = data[4:0];
	imm4 = data[3:0];
	
	offset6 = data[5:0];
	offset9 = data[8:0];
	offset11 = data[10:0];
	trapvect8 = data[7:0];
	*/
end

endmodule : ir
