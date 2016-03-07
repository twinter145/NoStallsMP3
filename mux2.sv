//creates 2 input module, sets up output
module mux2 #(parameter width = 16)
(
input sel,
input [width-1:0] a, b,
output logic [width-1:0] f
);

//internal workings of mux
always_comb
begin
if (sel == 0)
f = a;
else
f = b;
end
endmodule : mux2