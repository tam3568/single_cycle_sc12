module IMEM (
    input  [31:0] addr,
    output [31:0] Instruction
);
    parameter IMEM_DEPTH = 128;
    reg [31:0] memory [0:255];
    assign Instruction = (addr[11:2] < IMEM_DEPTH) ? memory[addr[11:2]] : 32'h00000063;

    initial begin
        integer i;

        `ifdef SC2
            $display("IMEM: loading imem2.hex");
            $readmemh("./mem/imem2.hex", memory);
        `else
            $display("IMEM: loading imem.hex");
            $readmemh("./mem/imem.hex", memory);
        `endif

        // In nội dung 5 dòng đầu tiên
        for (i = 0; i < 5; i = i + 1) begin
            $display("IMEM%0d: %08x", i, memory[i]);
        end
    end
endmodule
