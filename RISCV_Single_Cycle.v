module RISCV_Single_Cycle (
    input logic clk,
    input logic rst_n
);

    // --- Internal wires and signals ---
    logic [31:0] PC, NextPC;
    logic [31:0] Instruction;
    logic [4:0] rs1, rs2, rd;
    logic [6:0] funct7;
    logic [2:0] funct3;
    logic [6:0] opcode;
    logic [31:0] ImmExt;
    logic [31:0] ReadData1, ReadData2;
    logic [31:0] ALU_result;
    logic [31:0] WriteData;
    logic [31:0] ReadData;
    logic Branch, MemRead, MemToReg, MemWrite, RegWrite;
    logic [1:0] ALUSrc;
    logic [3:0] ALUOp;
    logic [3:0] ALUControl;
    logic Zero, BrTaken;

    // --- Fetch PC ---
    PC pc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .NextPC(NextPC),
        .PC(PC)
    );

    // --- Instruction Memory ---
    IMEM imem (
        .addr(PC),
        .Instruction(Instruction)
    );

    assign opcode = Instruction[6:0];
    assign rd     = Instruction[11:7];
    assign funct3 = Instruction[14:12];
    assign rs1    = Instruction[19:15];
    assign rs2    = Instruction[24:20];
    assign funct7 = Instruction[31:25];

    // --- Control Unit ---
    control_unit CU (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg),
        .RegWrite(RegWrite)
    );

    // --- Register File ---
    RegisterFile RF (
        .clk(clk),
        .rst_n(rst_n),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .RegWrite(RegWrite),
        .WriteData(WriteData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    // --- Immediate Generator ---
    Imm_Gen IG (
        .inst(Instruction),
        .imm_out(ImmExt)
    );

    // --- ALU Decoder ---
    ALU_decoder ALUDec (
        .alu_op(ALUOp[1:0]),
        .funct3(funct3),
        .funct7b5(funct7[5]),
        .alu_control(ALUControl)
    );

    // --- ALU ---
    logic [31:0] SrcB;
    assign SrcB = (ALUSrc == 2'b00) ? ReadData2 :
                  (ALUSrc == 2'b01) ? ImmExt :
                  (ALUSrc == 2'b10) ? ImmExt : 32'b0;

    ALU alu (
        .A(ReadData1),
        .B(SrcB),
        .ALUOp(ALUControl),
        .Result(ALU_result),
        .Zero(Zero)
    );

    // --- Branch Comparator ---
    Branch_Comp BC (
        .A(ReadData1),
        .B(ReadData2),
        .Branch(Branch),
        .funct3(funct3),
        .BrTaken(BrTaken)
    );

    // --- Data Memory ---
    DMEM dmem (
        .clk(clk),
        .rst_n(rst_n),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .addr(ALU_result),
        .WriteData(ReadData2),
        .ReadData(ReadData)
    );

    // --- Write-back MUX ---
    assign WriteData = MemToReg ? ReadData : ALU_result;

    // --- PC Update Logic ---
    logic [31:0] PCPlus4 = PC + 4;
    logic [31:0] BranchAddr = PC + ImmExt;

    assign NextPC = BrTaken ? BranchAddr : PCPlus4;

endmodule