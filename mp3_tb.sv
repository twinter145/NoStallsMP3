module mp3_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;
logic mem_resp_a;
logic mem_read_a;
logic mem_write_a;
logic [1:0] mem_wmask_a;
logic [15:0] mem_address_a;
logic [15:0] mem_rdata_a;
logic [15:0] mem_wdata_a;

logic mem_resp_b;
logic mem_read_b;
logic mem_write_b;
logic [1:0] mem_wmask_b;
logic [15:0] mem_address_b;
logic [15:0] mem_rdata_b;
logic [15:0] mem_wdata_b;

/* Clock generator */
initial clk = 0;
always #5 clk = ~clk;

mp3 dut
(
    .clk,
	 .mem_read_a(mem_read_a),
    .mem_write_a(mem_write_a),
    .mem_wmask_a(mem_wmask_a),
    .mem_address_a(mem_address_a),
    .mem_wdata_a(mem_wdata_a),
    .mem_resp_a(mem_resp_a),
    .mem_rdata_a(mem_rdata_a),
	 //b
    .mem_read_b(mem_read_b),
    .mem_write_b(mem_write_b),
    .mem_wmask_b(mem_wmask_b),
    .mem_address_b(mem_address_b),
    .mem_wdata_b(mem_wdata_b),
    .mem_resp_b(mem_resp_b),
    .mem_rdata_b(mem_rdata_b)
);

magic_memory_dp memory
(
    .clk,
	 //a
    .read_a(mem_read_a),
    .write_a(mem_write_a),
    .wmask_a(mem_wmask_a),
    .address_a(mem_address_a),
    .wdata_a(mem_wdata_a),
    .resp_a(mem_resp_a),
    .rdata_a(mem_rdata_a),
	 //b
    .read_b(mem_read_b),
    .write_b(mem_write_b),
    .wmask_b(mem_wmask_b),
    .address_b(mem_address_b),
    .wdata_b(mem_wdata_b),
    .resp_b(mem_resp_b),
    .rdata_b(mem_rdata_b)
);

endmodule : mp3_tb
