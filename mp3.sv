import lc3b_types::*;

module mp3
(
    input clk,

    /* Memory signals */
	 //inputs
	input pmem_resp,
	input lc3b_line pmem_rdata,
    //outputs
	output lc3b_line pmem_wdata,
	output lc3b_word pmem_address,
	output logic pmem_write,
	output logic pmem_read
);
//internal signals

//Datapath to cache signals
logic mem_resp_a;
lc3b_word mem_rdata_a;
logic mem_read_a;
logic mem_write_a;
lc3b_mem_wmask mem_wmask_a;
lc3b_word mem_address_a;
lc3b_word mem_wdata_a;
logic mem_resp_b;
lc3b_word mem_rdata_b;
logic mem_read_b;
logic mem_write_b;
lc3b_mem_wmask mem_wmask_b;
lc3b_word mem_address_b;
lc3b_word mem_wdata_b;

//cache to arbiter signals
lc3b_word I_address;
logic I_read;
lc3b_line I_rdata;
logic I_resp;
lc3b_line D_wdata;
lc3b_word D_address;
logic D_read;
logic D_write;
lc3b_line D_rdata;
logic D_resp;

//datapath
datapath datapath
(
	.clk,
	.mem_resp_a(mem_resp_a),
	.mem_rdata_a(mem_rdata_a),
	.mem_resp_b(mem_resp_b),
	.mem_rdata_b(mem_rdata_b),
	.mem_read_a(mem_read_a),
	.mem_write_a(mem_write_a),
	.mem_wmask_a(mem_wmask_a),
	.mem_address_a(mem_address_a),
	.mem_wdata_a(mem_wdata_a),
	.mem_read_b(mem_read_b),
	.mem_write_b(mem_write_b),
	.mem_wmask_b(mem_wmask_b),
	.mem_address_b(mem_address_b),
	.mem_wdata_b(mem_wdata_b)
);

//cache
arbiter ID_arbiter
(
	.clk(clk),
	.I_address(I_address),
	.I_read(I_read),
	.I_rdata(I_rdata),
	.I_resp(I_resp),
	.D_wdata(D_wdata),
	.D_address(D_address),
	.D_read(D_read),
	.D_write(D_write),
	.D_rdata(D_rdata),
	.D_resp(D_resp),
	.L2_rdata(pmem_rdata),
	.L2_resp(pmem_resp),
	.L2_wdata(pmem_wdata),
	.L2_address(pmem_address),
	.L2_read(pmem_read),
	.L2_write(pmem_write)
);

I_cache instruction_cache
(
	.clk(clk),
	.address(mem_address_a),
	.I_rdata(I_rdata),
	.I_resp(I_resp),
	.read(mem_read_a),
	.rdata(mem_rdata_a),
	.I_address(I_address),
	.I_read(I_read),
	.resp(mem_resp_a)
);

D_cache data_cache
(
	.clk(clk),
	.pmem_rdata(D_rdata),
	.pmem_resp(D_resp),
	.pmem_read(D_read),
	.pmem_write(D_write),
	.pmem_wdata(D_wdata),
	.pmem_address(D_address),
	.mem_resp(mem_resp_b),
	.mem_rdata(mem_rdata_b),
	.mem_read(mem_read_b),
	.mem_write(mem_write_b),
	.mem_byte_enable(mem_wmask_b),
	.mem_address(mem_address_b),
	.mem_wdata(mem_wdata_b)
);
/*
L2_cache l2_cache
(
	.clk(clk),
	.pmem_rdata(),
	.pmem_resp(),
	.pmem_read(),
	.pmem_write(),
	.pmem_wdata(),
	.pmem_address(),
	.L2_resp(),
	.L2_rdata(),
	.L2_read(),
	.L2_write(),
	.L2_address(),
	.L2_wdata()
);
*/
endmodule : mp3
