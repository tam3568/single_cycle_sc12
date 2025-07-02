// PC.v
module PC (
    input  logic clk,
    input  logic rst_n,
    input  logic [31:0] NextPC,
    output logic [31:0] PC
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            PC <= 32'b0;
        else
            PC <= NextPC;
    end
endmodule
