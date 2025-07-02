// RISCV_Single_Cycle.v - Đảm bảo pass cả 2 testbench SC1 và SC2
module RISCV_Single_Cycle(
    input logic clk,
    input logic rst_n,
    output logic [31:0] PC_out_top,
    output logic [31:0] Instruction_out_top
);

    logic [31:0] PC_next;

    logic [4:0] rs1, rs2, rd;
    logic [2:0] funct3;
    logic [6:0] opcode, funct7;

    logic [31:0] Imm;
    logic [31:0] ReadData1, ReadData2, WriteData;
    logic [31:0] ALU_in2, ALU_result;
    logic ALUZero;
    logic [31:0] MemReadData;

    logic [1:0] ALUSrc;
    logic [3:0] ALUCtrl;
    logic Branch, MemRead, MemWrite, MemToReg;
    logic RegWrite, PCSel;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            PC_out_top <= 32'b0;
        else
            PC_out_top <= PC_next;
    end

    // Instruction Memory
    IMEM IMEM_inst(
        .addr(PC_out_top),
        .Instruction(Instruction_out_top)
    );

    assign opcode = Instruction_out_top[6:0];
    assign rd     = Instruction_out_top[11:7];
    assign funct3 = Instruction_out_top[14:12];
    assign rs1    = Instruction_out_top[19:15];
    assign rs2    = Instruction_out_top[24:20];
    assign funct7 = Instruction_out_top[31:25];

    // Immediate generator
    Imm_Gen imm_gen(
        .inst(Instruction_out_top),
        .imm_out(Imm)
    );

    // Register file (instance name must be Reg_inst)
    RegisterFile Reg_inst(
        .clk(clk),
        .rst_n(rst_n),
        .RegWrite(RegWrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .WriteData(WriteData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    // Control Unit
    control_unit CU(
        .opcode(opcode),
        .ALUSrc(ALUSrc),
        .MemToReg(MemToReg),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .PCSel(PCSel),
        .ALUOp()
    );

    // ALU Decoder
    ALU_decoder alu_dec(
        .funct7(funct7),
        .funct3(funct3),
        .ALUOp(),
        .ALUCtrl(ALUCtrl)
    );

    // ALU
    ALU alu(
        .A(ReadData1),
        .B(ALU_in2),
        .ALUCtrl(ALUCtrl),
        .Result(ALU_result),
        .Zero(ALUZero)
    );

    assign ALU_in2 = (ALUSrc == 2'b00) ? ReadData2 : Imm;

    // Data Memory (instance name must be DMEM_inst)
    DMEM DMEM_inst(
        .clk(clk),
        .addr(ALU_result),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .WriteData(ReadData2),
        .ReadData(MemReadData)
    );

    assign WriteData = MemToReg ? MemReadData : ALU_result;
    assign PC_next = PCSel ? (PC_out_top + Imm) : (PC_out_top + 4);

endmodule
