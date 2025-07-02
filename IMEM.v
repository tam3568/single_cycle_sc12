module IMEM (
    input  [31:0] addr,
    output [31:0] Instruction
);
    parameter IMEM_DEPTH = 128; // Số lệnh thực tế trong imem.hex
    reg [31:0] memory [0:255];
    assign Instruction = (addr[11:2] < IMEM_DEPTH) ? memory[addr[11:2]] : 32'h00000063;

    initial begin
        if ($fopen("./mem/imem2.hex", "r"))
            $readmemh("./mem/imem2.hex", memory);
        else if ($fopen("./mem/imem.hex", "r"))
            $readmemh("./mem/imem.hex", memory);
        $display("IMEM0: %h", memory[0]);
        $display("IMEM1: %h", memory[1]);
        $display("IMEM2: %h", memory[2]);
    end
endmodule