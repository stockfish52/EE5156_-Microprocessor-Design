module ImmGen (
    input  wire [31:0] instruction,  // 32-bit instruction
    output reg  [31:0] imm           // Immediate output (32-bit)
);

    // Trích xuất opcode từ instruction
    wire [6:0] opcode = instruction[6:0];

    // Định nghĩa các opcode của RISC-V 32I
    localparam OP_I     = 7'b0010011; // I-type (ADDI, etc.)
    localparam OP_L     = 7'b0000011; // Load (LW)
    localparam OP_S     = 7'b0100011; // Store (SW)
    localparam OP_B     = 7'b1100011; // Branch (BEQ, etc.)
    localparam OP_JAL   = 7'b1101111; // JAL
    localparam OP_JALR  = 7'b1100111; // JALR
    localparam OP_LUI   = 7'b0110111; // LUI
    localparam OP_AUIPC = 7'b0010111; // AUIPC

    always @(*) begin
        case (opcode)
            OP_I, OP_L, OP_JALR: begin // I-type (bao gồm Load và JALR)
                imm = {{20{instruction[31]}}, instruction[31:20]}; // Sign-extend từ bit 31
            end

            OP_S: begin // S-type (Store)
                imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // Sign-extend
            end

            OP_B: begin // B-type (Branch)
                imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], 
                       instruction[11:8], 1'b0}; // Sign-extend, thêm 0 ở LSB
            end

            OP_JAL: begin // J-type (JAL)
                imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], 
                       instruction[30:21], 1'b0}; // Sign-extend, thêm 0 ở LSB
            end

            OP_LUI, OP_AUIPC: begin // U-type
                imm = {instruction[31:12], 12'b0}; // Shift left 12 bits, điền 0 vào LSB
            end

            default: begin
                imm = 32'b0; // Giá trị mặc định nếu opcode không hợp lệ
            end
        endcase
    end

endmodule
