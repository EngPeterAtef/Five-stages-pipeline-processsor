module ProcessorTb();
  reg clk;
  reg reset;
  reg interupt;
  reg [15:0]In_Port;
  wire [15:0]Out_Port;

  Processor cpu(
              clk,
              In_Port,
              reset,
              interupt,
              Out_Port
            );

  parameter clock_period = 50;
  initial
  begin
    clk = 1;
    reset = 1;
    interupt = 0;
    #1
     reset = 0;
    // In_Port = 16'h5;

    // test case : memory
    // #99
    //  In_Port = 16'h19;
    // #49
    //  In_Port = 16'hF;
    // #49
    //  In_Port = 16'hFFFFF320;
    //test case: 2 operands
    #99
     In_Port = 16'h5;
    #49
     In_Port = 16'h19;
    #49
     In_Port = 16'hFFFF;
    #49
     In_Port = 16'hF320;
    #199
     interupt = 1;
    #49
     interupt = 0;
    //test case : branch and interrupt
    // #(495*clock_period)
    //  In_Port = 16'h300;
    // #49
    //  In_Port = 16'h40;
    // #49
    //  In_Port = 16'h500;
    // #49
    //  In_Port = 16'h100;
    // #49
    //  In_Port = 16'h07fe;
    // #49
    //  In_Port = 16'h700;
    // interupt = 1;
    // #49
    //  interupt = 0;
    // make interrupt in cycle 6
    // #30
    // interupt = 1;
    // #20
    // interupt = 0;


    // #(10*50)
    // // make interrupt in cycle 17
    // interupt = 1;
    // #50
    // interupt = 0;



    // #149
    // reset = 1;
    // #1
    // reset = 0;

    // #49
    //  #(2*clock_period)
    //  In_Port = 16'h19;
    // #(clock_period)
    //  In_Port = 16'hFFFFFFFF;
    // #(2*clock_period)
    //  interupt = 1;
    // #(3*clock_period)
    //  interupt = 0;
    // In_Port = 16'hFFFFF320;
  end

  always #25 clk =~ clk;
endmodule
