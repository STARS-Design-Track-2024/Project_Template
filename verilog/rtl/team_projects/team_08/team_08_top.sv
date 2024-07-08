`default_nettype none

module top 
(
  // I/O ports
  input  logic hwclk, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue

  // UART ports
  // output logic [7:0] txdata,
  // input  logic [7:0] rxdata,
  // output logic txclk, rxclk,
  // input  logic txready, rxready
);

  // Simple Tests
  // assign right[1] = pb[0];
  // assign left[7] = pb[1];
  // assign left[7] = hwclk;

  // PLL Tests
  // pll mypll (.in_clk(hwclk), .lcd_clk(right[0]), .locked());
  // assign left[7] = hwclk;
 // assign left[7] = pb[1];
  // Instantiate top module

logic [19:0] empty;
logic blinkToggle;
logic [6:0] scoreDisplayed;

team_08_GPIOPins game(
  .clk(hwclk), .reset(reset), .in({11'd0, pb[17], pb[18], ~pb[19], 20'd0}), 
  .out({right[5], right[6], empty, scoreDisplayed, right[4:0]})
);

// assign ss0[6:0] = 7'b1100111;
// assign ss1[6:0] = blinkToggle;

always_comb begin
if(right[6]) begin
        ss0[6:0] = scoreDisplayed;
        ss0[7] = 0;
        ss1 = 0;
        
    end
    else begin
        ss1[6:0] = scoreDisplayed;
        ss1[7] = 0;
        ss0 = 0;      
    end
end
endmodule
