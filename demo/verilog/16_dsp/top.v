`include "calc.v"
`include "calc_dsp.v"

module top(input CLK, output LED_RED_N, output LED_GRN_N, output LED_BLU_N);

   wire correct;

   //implementation without DSP
   // calc calc_inst(
   //    .clk(clk), .correct(correct)
   // );

   //implementation with DSP
   calc_dsp calc_dsp_inst(
      .clk(CLK), .correct(correct)
   );

  //leds are active low
  assign LED_RED_N = ~correct;
  assign LED_GRN_N = ~correct;
  assign LED_BLU_N = ~correct;

  initial begin
  end

  always @(posedge CLK)
  begin
  end

endmodule
