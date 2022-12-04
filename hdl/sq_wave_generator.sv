/*
  Outputs a pulse generator with a period of "ticks".
  out should go high for one cycle ever "ticks" clocks.
*/
module square_wave_generator(clk, rst, ena, pitch_ticks, out);

parameter N = 8;
input wire clk, rst, ena;
input wire [N-1:0] pitch_ticks;
output logic out;


enum logic {
  LOW,
  HIGH
} state;
logic [N-1:0] counter;


always_ff @(posedge clk) begin
  if(rst) begin
    counter <= 0;
    state <= LOW;
  end else if(ena) begin
    case (state)
      LOW: begin
        out <= 0;
        if (counter == pitch_ticks) begin
          counter <= 0;
          state <= HIGH;
        end
        else begin
          counter <= counter + 1;
        end
      end
      HIGH: begin
        out <= 1;
        if (counter == pitch_ticks) begin
          counter <= 0;
          state <= LOW;
        end
        else begin
          counter <= counter + 1;
        end
      end
    endcase
  end
end

endmodule
