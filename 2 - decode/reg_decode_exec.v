module reg_decode_exec(
    input clk,
    input [15:0]Imm_value,
    input [4:0]shmnt,
    input [15:0]Rs_data,
    input [15:0]Rd_data,
    input [2:0] Rd,
    input [33:0] control_signals,
    input [2:0] Rs,
    


    output reg [15:0]Imm_value_execute,
    output reg [4:0]shmnt_execute,
    output reg [15:0]Rs_data_execute,
    output reg [15:0]Rd_data_execute,
    output reg [2:0] Rd_execute,
    output reg [33:0] control_signals_execute,
    output reg [2:0] Rs_execute
);
    reg [92:0] register;
    initial begin   // this solves the problem of the forwading unit not working on first 2 instruction as there is not values inside intermediate registers
        register = 0;
    end
    // always @(Rs_data,Rd_data) begin
    //     register[26:11] <= Rd_data;
    //     register[42:27] <= Rs_data;
    // end

    always @ (negedge clk,Rs_data,Rd_data,Imm_value) // read at the +ve edge
    begin
        register[33:0] <= control_signals;
        register[36:34] <= Rd;
        register[52:37] <= Rd_data;
        register[68:53] <= Rs_data;
        register[73:69] <= shmnt;
        register[89:74] <= Imm_value;
        register[92:90] <= Rs;
    end

    always @ (posedge clk) // write at the -ve edge
    begin
        control_signals_execute = register[33:0] ;
        Rd_execute              = register[36:34];
        Rd_data_execute         = register[52:37];
        Rs_data_execute         = register[68:53];
        shmnt_execute           = register[73:69];
        Imm_value_execute       = register[89:74];
        Rs_execute              = register[92:90];
    end

endmodule