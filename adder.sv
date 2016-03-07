//inputs, outputs
module adder #(parameter width = 16)
(
input logic [width-1:0] a, b,
output logic [width-1:0] f
);

//internal workings
always_comb
begin
f = a+b;
end
endmodule : adder