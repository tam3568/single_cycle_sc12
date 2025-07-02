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
    logic [31:0] RD1, RD2;
    logic [31:0] ALU_result;
    logic [31:0] WriteData;
    logic [31:0] ReadData;
    logic Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Jump;
    logic [1:0] ALUOp;
    logic [3:0] ALUControl;
    logic Zero, TakeBranch;

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
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jump(Jump)
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
        .RD1(RD1),
        .RD2(RD2)
    );

    // --- Immediate Generator ---
    Imm_Gen IG (
        .instruction(Instruction),
        .ImmExt(ImmExt)
    );

    // --- ALU Decoder ---
    ALU_decoder ALUDec (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );

    // --- ALU ---
    logic [31:0] SrcB;
    assign SrcB = ALUSrc ? ImmExt : RD2;

    ALU alu (
        .A(RD1),
        .B(SrcB),
        .ALUControl(ALUControl),
        .Result(ALU_result),
        .Zero(Zero)
    );

    // --- Branch Comparator ---
    Branch_Comp BC (
        .A(RD1),
        .B(RD2),
        .funct3(funct3),
        .TakeBranch(TakeBranch)
    );

    // --- Data Memory ---
    DMEM dmem (
        .clk(clk),
        .rst_n(rst_n),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .addr(ALU_result),
        .WriteData(RD2),
        .ReadData(ReadData)
    );

    // --- Write-back MUX ---
    assign WriteData = MemtoReg ? ReadData : ALU_result;

    // --- PC Update Logic ---
    logic [31:0] PCPlus4 = PC + 4;
    logic [31:0] BranchAddr = PC + ImmExt;

    assign NextPC = Jump              ? ALU_result :
                    (Branch && TakeBranch) ? BranchAddr :
                    PCPlus4;

endmodule