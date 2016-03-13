import lc3b_types::*;

module mp3
(
    input clk,

    /* Memory signals */
	 //inputs
	 input mem_resp_a,
    input lc3b_word mem_rdata_a,
	 input mem_resp_b,
    input lc3b_word mem_rdata_b,
    //outputs
    output mem_read_a,
    output mem_write_a,
    output [1:0] mem_wmask_a,
    output lc3b_word mem_address_a,
    output lc3b_word mem_wdata_a,
	 output mem_read_b,
    output mem_write_b,
    output [1:0] mem_wmask_b,
    output lc3b_word mem_address_b,
    output lc3b_word mem_wdata_b
);
//internal signals


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

//cache???

endmodule : mp3
