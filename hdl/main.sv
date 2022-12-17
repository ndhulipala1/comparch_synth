`default_nettype none
`timescale 1ns / 1ps

module main(/*AUTOARG*/
   // Outputs
   gain, leds, pwm_out, shutdown_b,
   // Inputs
   buttons, clk, rst
   );
   parameter NUM_CHANNELS = 2;
   parameter NUM_BUTTONS  = NUM_CHANNELS + 2; // waveform select, demo

   input wire clk, rst;

   input  wire  [NUM_BUTTONS-1:0] buttons; // Bus of all button inputs
   output wire                    pwm_out; // Driven by module
   output logic                   shutdown_b, gain; // For the pmodamp2
   output logic [1:0]             leds;

   // Debounce all buttons
   logic [NUM_BUTTONS-1:0] buttons_db;
   bus_debouncer #(.N(NUM_BUTTONS)) BUS_DEBOUNCER (.clk           (clk),
                                                   .rst           (rst),
                                                   .bouncy_in     (buttons),
                                                   .debounced_out (buttons_db));

   // Debug LEDs
   always_comb begin
      leds[0] = channel_ena[0];
      leds[1] = channel_ena[1];
   end

   // Tie amp control signals
   always_comb begin
      shutdown_b = 1; // Should remain high
      gain       = 1; // 0 is 12DB, 1 is 6DB
   end

   //////////////////////////
   // Synth Implementation //
   //////////////////////////
   enum logic {PLAY=0, DEMO=1} state;

   always_ff @(posedge clk) begin
      if (rst) begin
         state <= PLAY;
      end
      if (button_demo_db) begin
         state <= DEMO;
      end else if (|buttons_db) begin
         state <= PLAY;
      end
   end

   // Map buttons and pitches
   logic [     NUM_CHANNELS-1:0] channel_ena;
   logic [(NUM_CHANNELS* 2)-1:0] waveforms;
   logic [(NUM_CHANNELS*12)-1:0] pitches;
   logic                         button_waveform, button_demo_db;

   always_comb begin
      button_waveform     = buttons_db[0];
      button_demo_db      = buttons_db[1];
      case (state)
        PLAY: begin
           channel_ena    = buttons[NUM_BUTTONS-1:2];
           waveforms      = {NUM_CHANNELS{waveform_type}};
           // Hardcoded for 2 channels
           pitches[11: 0] = 212; // A4
           pitches[23:12] = 106; // A5
        end
        DEMO: begin
           channel_ena    = 0; // Have all channels off until memory is works
           waveforms      = 0;
           pitches        = -1;
        end
      endcase
   end

   // Get waveform type inputted
   logic [1:0] waveform_type;
   get_waveform WAVEFORM_MODE(// Outputs
                              .waveform_out    (waveform_type),
                              // Inputs
                              .clk             (clk),
                              .rst             (rst),
                              .ena             (1'b1),
                              .waveform_button (button_waveform));

   // Instantiate channel mixer
   wire [11:0] audio;
   channel_mixer #(.NUM(NUM_CHANNELS), .C(12))
   CHANNEL_MIXER(// Outputs
                 .audio       (audio),
                 // Inputs
                 .pitches     (pitches),
                 .channel_ena (channel_ena),
                 .waveforms   (waveforms),
                 .clk         (clk),
                 .rst         (rst));

   // Instantiate PWM generator
   audio_pwm_generator PWM_GENERATOR (.ena              (1'b1),
                                      /*AUTOINST*/
                                      // Outputs
                                      .pwm_out          (pwm_out),
                                      // Inputs
                                      .audio            (audio[11:0]),
                                      .clk              (clk),
                                      .rst              (rst));

endmodule
