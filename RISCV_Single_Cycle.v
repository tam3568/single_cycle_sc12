module RISCV_Single_Cycle(
    input logic clk,
    input logic rst_n,
    output logic [31:0] PC_out_top,
    output logic [31:0] Instruction_out_top
);

    // --- Internal wires and signals ---
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

    // --- PC Register (moved to PC.v) ---
    PC pc_reg (
        .clk(clk),
        .rst_n(rst_n),
        .NextPC(PC_next),
        .PC(PC_out_top)
    );

    // --- Instruction Memory ---
    IMEM IMEM_inst(
        .addr(PC_out_top),
        .Instruction(Instruction_out_top)
    );

    // --- Instruction field decoding ---
    assign opcode = Instruction_out_top[6:0];
    assign rd     = Instruction_out_top[11:7];
    assign funct3 = Instruction_out_top[14:12];
    assign rs1    = Instruction_out_top[19:15];
    assign rs2    = Instruction_out_top[24:20];
    assign funct7 = Instruction_out_top[31:25];

    // --- Immediate Generator ---
    Imm_Gen imm_gen(
        .inst(Instruction_out_top),
        .imm_out(Imm)
    );

    // --- Register File ---
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

    // --- ALU Input Selection ---
    assign ALU_in2 = (ALUSrc[0]) ? Imm : ReadData2;

    // --- ALU ---
    ALU alu(
        .A(ReadData1),
        .B(ALU_in2),
        .ALUOp(ALUCtrl),
        .Result(ALU_result),
        .Zero(ALUZero)
    );

    // --- Data Memory ---
    DMEM DMEM_inst(
        .clk(clk),
        .rst_n(rst_n),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .addr(ALU_result),
        .WriteData(ReadData2),
        .ReadData(MemReadData)
    );

    // --- Write-back MUX ---
    assign WriteData = (MemToReg) ? MemReadData : ALU_result;

    // --- Control Unit ---
    control_unit ctrl(
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUCtrl),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg),
        .RegWrite(RegWrite)
    );

    // --- Branch Comparator ---
    Branch_Comp comp(
        .A(ReadData1),
        .B(ReadData2),
        .Branch(Branch),
        .funct3(funct3),
        .BrTaken(PCSel)
    );

    // --- Next PC Logic ---
    assign PC_next = (PCSel) ? PC_out_top + Imm : PC_out_top + 4;

endmodule
