`include "../1 - fetch/fetch_stage.v"
`include "../1 - fetch/instruction_memory.v"
`include "../1 - fetch/reg_fetch_decode.v"

`include "../2 - decode/instruction_decode.v"
`include "../2 - decode/reg_decode_exec.v"
`include "../2 - decode/reg_file.v"
`include "../2 - decode/control_unit.v"

`include "../3 - execute/ALU.v"
`include "../3 - execute/reg_exec_mem.v"

`include "../4 - memory/memory_stage.v"
`include "../4 - memory/reg_mem_wb.v"
`include "../4 - memory/data_memory.v"

module Processor (
    input clk
);
    reg [2:0] CCR; // flag register


    // fetch stage
    reg [31:0] jumpAddress;
    wire [31:0] nextInstructionAddress;
    wire isImmediate;
    wire [4:0] SHMNT;
    wire [2:0] Rd;
    wire [2:0] Rs;
    wire [4:0] opCode;
    FetchStage Fetch(32'b0,32'b0,isImmediate,nextInstructionAddress,SHMNT,Rd,Rs,opCode,clk);
    
    // register between fetch and decode
    wire [31:0] Next_inst_addr_decode;
    wire [4:0]  opcode_decode;
    wire [2:0]  Rs_decode;
    wire [2:0]  Rd_decode;
    wire [4:0]  shmnt_decode;
    reg_fetch_decode reg_fetch_decode(clk,nextInstructionAddress,opCode,Rs,Rd,SHMNT,
    Next_inst_addr_decode,opcode_decode,Rs_decode,Rd_decode,shmnt_decode);

    // decode stage
    reg  [15:0] WB_data;
    reg  [2:0] WB_address;
    reg write_enable;
    reg rst;
    reg rstAll;
    wire [15:0] Rs_data;
    wire [15:0] Rd_data;
    wire [7:0] control_signals;
    instruction_decode Decode(clk,opcode_decode,Rs_decode,Rd_decode,WB_data,WB_address,write_enable,rst,rstAll,Rs_data,Rd_data,control_signals);
    
    // register between decode and execute
    wire [15:0]Imm_value_execute;
    wire [4:0]shmnt_execute;
    wire [15:0]Rs_data_execute;
    wire [15:0]Rd_data_execute;
    wire [2:0] Rd_execute;
    wire [7:0] control_signals_execute;
    reg_decode_exec reg_dec_exec(clk,{opcode_decode,Rs_decode,Rd_decode,shmnt_decode},shmnt_decode,
    Rs_data,Rd_data,Rd_decode,control_signals,Imm_value_execute,shmnt_execute,Rs_data_execute,Rd_data_execute,Rd_execute,control_signals_execute);

    // execute stage
    wire [15:0] ALU_Result; // ALU 16-bit Output
    wire [2:0] ccr_out; // flags register
    ALU alu(Rs_data_execute,Rd_data_execute,control_signals_execute[1],control_signals_execute[0],ALU_Result,ccr_out,clk);
    always @(ccr_out) begin CCR = ccr_out; end

    // register between execute and memory
    wire [15:0] ALU_result_mem;
    wire [15:0] Rs_data_mem;
    wire [15:0] Rd_data_mem;
    wire [2:0] Rd_mem;
    wire  memRead_mem;
    wire  memWrite_mem;
    wire  regWrite_mem;
    reg_exec_mem reg_exec_mem(clk,ALU_Result,Rs_data_execute,Rd_data_execute,Rd_execute,control_signals_execute[2],control_signals_execute[3],control_signals_execute[4],ALU_result_mem,Rs_data_mem,Rd_data_mem,Rd_mem,memRead_mem,memWrite_mem,regWrite_mem);

    // memory stage
    wire [15:0] dataFromMemory;
    wire [15:0] MEMWB_ALU_result;
    wire [2:0] MEMWB_Rdst_address;
    wire MEMWB_memRead;
    wire MEMWB;
    MemoryStage memory_stage(ALU_result_mem,Rs_data_mem,Rd_data_mem,Rd_mem,regWrite_mem,memRead_mem,regWrite_mem,1'b0,1'b0,32'b0,
    dataFromMemory,MEMWB_ALU_result,MEMWB_Rdst_address,MEMWB_memRead,MEMWB,clk); // TODO : write push and pop and sp

    // register between memory and write back
    wire [15:0] dataFromMemory_WB;
    wire [15:0] MEMWB_ALU_result_WB;
    wire [2:0] MEMWB_Rdst_address_WB;
    wire MEMWB_memRead_WB;
    wire MEMWB_WB;
    reg_mem_WB reg_mem_WB(clk,dataFromMemory,MEMWB_ALU_result,MEMWB_Rdst_address,MEMWB_memRead,MEMWB,dataFromMemory_WB,MEMWB_ALU_result_WB,MEMWB_Rdst_address_WB,MEMWB_memRead_WB,MEMWB_WB);


endmodule