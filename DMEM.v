module DMEM (
    input logic clk,
    input logic rst_n,            // Thêm cổng reset
    input logic MemRead,
    input logic MemWrite,
    input logic [31:0] addr,
    input logic [31:0] WriteData,
    output logic [31:0] ReadData
);
    reg [31:0] memory [0:255];

    assign ReadData = (MemRead) ? memory[addr[9:2]] : 32'b0;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 256; i = i + 1)
                memory[i] <= 32'b0;
        end else if (MemWrite) begin
            memory[addr[9:2]] <= WriteData;
        end
    end
endmodule