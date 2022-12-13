module monostable (clk, rst, button, out);

// Inputs
input wire clk, rst;
input wire button;
// Outputs
output logic out;

// Keep track of current button state and previous button state
logic prev;
always_ff @(posedge clk) begin : monostable_fsm
    prev <= rst ? 0 : button;
end

always_comb begin
    out = button & ~prev;
end

endmodule