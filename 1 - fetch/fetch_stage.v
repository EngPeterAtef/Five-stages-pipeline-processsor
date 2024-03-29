// // a mux to set PC value
// module mux21(Addition, jump, S, Y);
// output [31:0] Y;
// input [31:0] jump, Addition;
// input S;

// always @(Addition or jump)
//     begin
//         case(S)
//             0: // Addition
//             Y <= Addition;
//             1: // jump
//             Y <= jump ;
//         endcase
//     end

// // assign Y=(S) ? jump : Addition;
// endmodule

module FetchStage (
    clk,
    enable,
    jumpAddress,
    isImmediate,
    nextInstructionAddress,
    SHMNT,
    Rd,
    Rs,
    opCode,
    LDM_signal,
    Inst_as_Imm_value,
    reset,
    interupt,
    int1_decode,
    int1_execute,
    int1_mem,
    int1_WB,
    pushflags,
    pushpc,
    popPc,
    popFlags,
    pop_flags_exec,
    rdst_call,
    return,
    branchSignal,
    unconditionalJump,
    PCFromPop,
    PC_of_cpu
  );
  // input
  input [31:0] jumpAddress;
  input [31:0] PCFromPop;
  input LDM_signal;
  input unconditionalJump;
  input clk;
  input enable;
  input reset;
  input pushflags;
  input pushpc;
  input popPc;
  input popFlags;
  input pop_flags_exec;
  input [2:0]rdst_call;
  input interupt;
  input int1_decode;
  input int1_execute;
  input int1_mem;
  input int1_WB;
  input return;
  input branchSignal;
  // IF/ID
  output reg [31:0] nextInstructionAddress;
  output reg isImmediate;
  output reg [4:0] SHMNT;
  output reg [2:0] Rd;
  output reg [2:0] Rs;
  output reg [4:0] opCode;
  output reg [15:0] Inst_as_Imm_value;
  output reg [31:0] PC_of_cpu;
  // TODO: make a mux and set PC value from MUX
  // TODO: make ALU to inrement PC by 1 ---> OR 2 ?
  reg [31:0] PC;
  reg [15:0] writeData;
  // always @(PC)
  //     begin
  //     	nextInstructionAddress <= PC + 32'h00000001;
  //     end
  // Selectors
  // Mux1
  wire [31:0]nextPCOrBranch;
  // Mux2
  wire[31:0] returnOrMux1;
  // Mux3
  wire [31:0]intOrMux2;
  // Mux4
  wire [31:0]rstOrMux3;

  reg CS;
  wire [15:0] dataFromMemoryWire;

  reg ldm;
  reg [31:0]rstOrMux3reg;


  // Instruction memory
  InstructionMemory mem(PC, writeData, dataFromMemoryWire, 1'b1, 1'b0, CS, clk);
  wire [15:0] mux_out;
  assign mux_out = (ldm | branchSignal | unconditionalJump | pop_flags_exec  | int1_decode | int1_execute | int1_mem)? 16'b0:
         (int1_WB == 1)? {16'b11110_000_000_00000}: // if signal int in WB ->  push flags for interrupt
         (pushflags == 1)? {8'b11111_000,rdst_call,5'b00000}: // if push flags from decode -> push pc
         (pushpc == 1)? {8'b11011_000,rdst_call,5'b00000}: //  if push pc from decode ->  jmpCall Rdst

         (popPc == 1)? {8'b11101_000,rdst_call,5'b00000}:  //  if pop pc from decode ->  pop flags

         dataFromMemoryWire;

  assign Inst_as_Imm_value = dataFromMemoryWire;

  assign nextPCOrBranch =
         ((branchSignal | unconditionalJump) == 1'b0) ? rstOrMux3reg + 32'b1 :
         ((branchSignal | unconditionalJump) == 1'b1) ? jumpAddress : 32'bz;
  assign returnOrMux1 =
         (return == 1'b0) ? nextPCOrBranch :
         (return == 1'b1) ? PCFromPop : 32'bz;
  // assign intOrMux2 =
  //     (interupt == 1'b0) ? returnOrMux1 :
  //     (interupt == 1'b1) ? 32'b0 : 32'bz;
  assign rstOrMux3 =
         (reset == 1'b0) ? returnOrMux1 :
         (reset == 1'b1) ? 32'b00100000 : 32'bz;
  assign PC_of_cpu = PC;
  always @(*)
  begin
    if(LDM_signal == 1)
    begin
      ldm = 1;
    end
    else
    begin
      ldm = 0;
    end
    SHMNT = mux_out[4:0];
    Rd = mux_out[7:5];
    Rs = mux_out[10:8];
    opCode = mux_out[15:11];


  end


  always @(*)
  begin
    CS = ~reset;
  end
  always @(posedge clk, negedge enable,posedge reset,return)
  begin
    if(enable == 1)
    begin
      rstOrMux3reg = rstOrMux3;
      PC = rstOrMux3reg;

    end
    // CS = 1;
  end
  // always @(posedge interupt) begin
  //     pcBeforeInterrupt_fetch = PC +1;
  // end
endmodule
