module debouncer(clk, rst, bouncy_in, debounced_out);

parameter BOUNCE_TICKS = 10;
input wire clk, rst;
input wire bouncy_in;

output logic debounced_out;

enum logic [1:0] {
  S_0 = 2'b00,
  S_MAYBE_1 = 2'b01,
  S_1 = 2'b10,
  S_MAYBE_0 = 2'b11
} state;

//clog2 = ceiling(log_base_2(x)) - how many bits do I need
logic [$clog2(BOUNCE_TICKS):0] counter;

always_ff @(posedge clk) begin : main_FSM
  if(rst) begin
    state <= S_0;
    counter <= 0;
  end else begin
    case (state)
      S_0: begin
        if(bouncy_in) begin
          state <= S_MAYBE_1;
          counter <= 0;
        end
      end
      S_1: begin
        if(~bouncy_in) begin
            state <= S_MAYBE_0;
            counter <= 0;
        end
      end
      S_MAYBE_0: begin
        if(counter >= BOUNCE_TICKS) begin // we've waited long enough
           state <= bouncy_in ? S_1 : S_0;
        end else begin
           counter <= counter + 1;
        end
      end
      S_MAYBE_1: begin
        if(counter >= BOUNCE_TICKS) begin // we've waited long enough
          state <= bouncy_in ? S_1 : S_0;
        end else begin
           counter <= counter + 1;
        end
      end
      default: state <= S_0; // This should never occur
    endcase
  end
end

always_comb begin
   case (state)
     S_0       : debounced_out = 0;
     S_MAYBE_1 : debounced_out = 0;
     S_1       : debounced_out = 1;
     S_MAYBE_0 : debounced_out = 1;
   endcase
end


endmodule;
