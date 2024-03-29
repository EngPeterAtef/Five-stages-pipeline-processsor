module reg_exec_mem(
    input clk,
    input reset,
    input [15:0] ALU_result,
    input [15:0] Rs_data,
    input [15:0] Rd_data,
    input [2:0] Rd,
    input  memRead,
    input  memWrite,
    input  regWrite,
    input  push,
    input  pop,
    input  [1:0]shmnt,
    input pushPc,
    input popPc,
    input pushCCR,
    input popCCR,
    input int1,
    input int2,

    output reg [15:0] ALU_result_mem,
    output reg [15:0] Rs_data_mem,
    output reg [15:0] Rd_data_mem,
    output reg [2:0] Rd_mem,
    output reg  memRead_mem,
    output reg  memWrite_mem,
    output reg  regWrite_mem,
    output reg  push_mem,
    output reg  pop_mem,
    output reg  [1:0]shmnt_mem,
    output reg pushPc_mem,
    output reg popPc_mem,
    output reg pushCCR_mem,
    output reg popCCR_mem,
    output reg int1_mem,
    output reg int2_mem
  );
  reg [63:0] register;
  always @(posedge reset)
  begin   // this solves the problem of the forwading unit not working on first 2 instruction as there is not values inside intermediate registers
    register = 0;
  end
  always @ (negedge clk) // write at the -ve edge
  begin
    register[15:0] <= ALU_result;
    register[31:16] <= Rs_data;
    register[47:32] <= Rd_data;
    register[50:48] <= Rd;
    register[51] <=  memRead;
    register[52] <=  memWrite;
    register[53] <=  regWrite;
    register[54] <=  push;
    register[55] <=  pop;
    register[57:56] <=  shmnt;
    register[58] <= pushPc;
    register[59] <= popPc;
    register[60] <= pushCCR;
    register[61] <= popCCR;
    register[62] <= int1;
    register[63] <= int2;
  end

  always @ (posedge clk) // read at the +ve edge
  begin
    ALU_result_mem = register[15:0];
    Rs_data_mem = register[31:16];
    Rd_data_mem = register[47:32];
    Rd_mem = register[50:48];
    memRead_mem = register[51];
    memWrite_mem = register[52];
    regWrite_mem = register[53];
    push_mem = register[54];
    pop_mem = register[55];
    shmnt_mem = register[57:56];
    pushPc_mem = register[58];
    popPc_mem = register[59];
    pushCCR_mem = register[60];
    popCCR_mem = register[61];
    int1_mem = register[62];
    int2_mem = register[63];
  end

endmodule
