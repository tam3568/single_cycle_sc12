module ALU_decoder(
    input  [1:0] alu_op,
    input  [2:0] funct3,
    input        funct7b5,
    output logic [3:0] alu_control
);
    always_comb begin
        alu_control = 4'b0000; // Gán mặc định: ADD (chuẩn cho load/store)
        case (alu_op)
            2'b00: alu_control = 4'b0010; // ADD (load/store)
            2'b01: alu_control = 4'b0110; // SUB (branch)
            2'b10: begin // R-type/I-type
                case (funct3)
                    3'b000: alu_control = (funct7b5 ? 4'b0001 : 4'b0000); // SUB : ADD
                    3'b111: alu_control = 4'b0010; // AND
                    3'b110: alu_control = 4'b0011; // OR
                    3'b100: alu_control = 4'b0100; // XOR
                    3'b001: alu_control = 4'b0101; // SLL
                    3'b101: alu_control = (funct7b5 ? 4'b0111 : 4'b0110); // SRA : SRL
                    3'b010: alu_control = 4'b1000; // SLT
                    3'b011: alu_control = 4'b1001; // SLTU
                    default: alu_control = 4'b0000;
                endcase
            end
            2'b11: begin // custom cho LUI, AUIPC nếu cần
                alu_control = 4'b1010; // LUI/AUIPC: chuyển imm hoặc PC+imm
            end
            default: alu_control = 4'b0000;
        endcase
    end
endmodule