module reg_mem_WB(
    input clk,
    input [15:0] dataFromMemory,
    input [15:0] MEMWB_ALU_result,
    input [2:0] MEMWB_Rdst_address,
    input MEMWB_memRead,
    input MEMWB,


    output reg [15:0] dataFromMemory_WB,
    output reg [15:0] MEMWB_ALU_result_wB,
    output reg [2:0] MEMWB_Rdst_address_WB,
    output reg MEMWB_memRead_WB,
    output reg MEMWB_WB
);
    reg [36:0] register;

    always @ (negedge clk) // read at the +ve edge
    begin
        register[15:0] <= dataFromMemory;
        register[31:16] <= MEMWB_ALU_result;
        register[34:32] <= MEMWB_Rdst_address;
        register[35] <= MEMWB_memRead;
        register[36] <= MEMWB;
    end

    always @ (posedge clk) // write at the -ve edge
    begin
        dataFromMemory_WB = register[15:0];
        MEMWB_ALU_result_wB = register[31:16];
        MEMWB_Rdst_address_WB = register[34:32];
        MEMWB_memRead_WB = register[35];
        MEMWB_WB = register[36];
    end

endmodule