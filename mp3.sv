import lc3b_types::*;

module mp3
(
    input clk,

    /* Memory signals */
	 //inputs
	 input mem_resp,
    input lc3b_word mem_rdata,
    //outputs
    output mem_read,
    output mem_write,
    output lc3b_mem_wmask mem_byte_enable,
    output lc3b_word mem_address,
    output lc3b_word mem_wdata
);
//internal signals


//datapath
datapath datapath
(
	.clk,
	.mem_resp,
	.mem_rdata,
	.mem_read,
	.mem_write,
	.mem_byte_enable,
	.mem_address,
	.mem_wdata
);

//cache???

endmodule : mp3
