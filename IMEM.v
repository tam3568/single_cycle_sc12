module IMEM (
    input  [31:0] addr,
    output [31:0] Instruction
);
    reg [31:0] memory [0:255];
    assign Instruction = (addr[9:2] < 100) ? memory[addr[9:2]] : 32'h00000013; // NOP nếu out of range

    initial begin
        $readmemh("./mem/imem2.hex", memory);
        $display("IMEM0: %h", memory[0]);
        $display("IMEM1: %h", memory[1]);
        $display("IMEM2: %h", memory[2]);
    end
endmodule
