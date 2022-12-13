module bus_debouncer(clk, rst, bouncy_in, debounced_out);

parameter N = 1;

// Inputs
input wire clk, rst;
input wire [N-1:0] bouncy_in;
// Outputs
output logic [N-1:0] debounced_out;

generate
    genvar i;
    for (i=0; i<N; i++) begin
        debouncer DEBOUNCE_ONE_BIT (
            .clk(clk),
            .rst(rst),
            .bouncy_in(bouncy_in[i]),
            .debounced_out(debounced_out[i])
        );
    end
endgenerate

endmodule