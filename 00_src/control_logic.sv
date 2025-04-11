module control_logic (
    input  wire [31:0] instruction,  // 32-bit instruction
    input  wire        BrEq,         // Branch Equal từ comparator
    input  wire        BrLT,         // Branch Less Than từ comparator
    output reg  [1:0]  OpA_sel,      // Select Operator A
    output reg         OpB_sel,      // Select Operator B
    output reg         RegWEn,       // Register Write Enable
    output reg         MemRW,        // Memory Read/Write (0: read, 1: write)
    output reg  [3:0]  ALUsel,       // ALU operation select
    output reg  [1:0]  WB_sel,       // Writeback select
    output reg         PCSel,        // PC select (0: PC+4, 1: branch/jump)
    output reg         BrUn,         // Branch Unsigned cho Branch Comp
    output reg  [2:0]  i_lsu_op      // LSU operation (size and signed/unsigned)
    //output reg         insn_vld      // Instruction valid signal    
);

    // Phân tách các trường của instruction
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];

    // Định nghĩa các opcode của RISC-V 32I
    localparam OP_R     = 7'b0110011; // R-type (ADD, SUB, AND, OR, etc.)
    localparam OP_I     = 7'b0010011; // I-type (ADDI, ANDI, ORI, etc.)
    localparam OP_L     = 7'b0000011; // Load (LW, LH, LB, etc.)
    localparam OP_S     = 7'b0100011; // Store (SW, SH, SB)
    localparam OP_B     = 7'b1100011; // Branch (BEQ, BNE, BLT, etc.)
    localparam OP_JAL   = 7'b1101111; // JAL
    localparam OP_JALR  = 7'b1100111; // JALR
    localparam OP_LUI   = 7'b0110111; // LUI
    localparam OP_AUIPC = 7'b0010111; // AUIPC

    always @(*) begin
        // Giá trị mặc định
        OpA_sel  = 2'b00;  // 00: rs1, 01: PC, 10: zero
        OpB_sel  = 1'b0;   // 0: rs2, 1: imm 
        RegWEn   = 1'b0;   // Không ghi register
        MemRW    = 1'b0;   // Đọc bộ nhớ
        ALUsel   = 4'b0000;// Mặc định ADD
        WB_sel   = 2'b00;  // 00: Mem, 01: ALU, 10: PC+4
        PCSel    = 1'b0;   // PC + 4
        BrUn     = 1'b0;   // Mặc định so sánh có dấu
        i_lsu_op = 3'b000; // Mặc định: word, không cần sign/zero extension
        //insn_vld = 1'b0;   // Mặc định: instruction không hợp lệ

        case (opcode)
            OP_R: begin // R-type instructions
                OpA_sel  = 2'b00;  // rs1
                OpB_sel  = 1'b0;   // rs2
                RegWEn   = 1'b1;   // Ghi kết quả vào register
                WB_sel   = 2'b01;  // Từ ALU
                //insn_vld = 1'b1;   // Instruction hợp lệ
                case (funct3)
                    3'b000: ALUsel = (funct7[5]) ? 4'b0001 : 4'b0000; // SUB : ADD
                    3'b001: ALUsel = 4'b0010; // SLL
                    3'b010: ALUsel = 4'b0100; // SLT
                    3'b011: ALUsel = 4'b0110; // SLTU
                    3'b100: ALUsel = 4'b1000; // XOR
                    3'b101: ALUsel = (funct7[5]) ? 4'b1011 : 4'b1010; // SRA : SRL
                    3'b110: ALUsel = 4'b1100; // OR
                    3'b111: ALUsel = 4'b1110; // AND
                endcase
            end

            OP_I: begin // I-type instructions
                OpA_sel  = 2'b00;  // rs1
                OpB_sel  = 1'b1;   // immediate
                RegWEn   = 1'b1;   // Ghi kết quả vào register
                WB_sel   = 2'b01;  // Từ ALU
                //insn_vld = 1'b1;   // Instruction hợp lệ
                case (funct3)
                    3'b000: ALUsel = 4'b0000; // ADDI
                    3'b001: ALUsel = 4'b0010; // SLLI
                    3'b010: ALUsel = 4'b0100; // SLTI
                    3'b011: ALUsel = 4'b0110; // SLTUI
                    3'b100: ALUsel = 4'b1000; // XORI
                    3'b101: ALUsel = (funct7[5]) ? 4'b1011 : 4'b1010; // SRAI : SRLI
                    3'b110: ALUsel = 4'b1100; // ORI
                    3'b111: ALUsel = 4'b1110; // ANDI
                endcase
            end

            OP_L: begin // Load (LW, LH, LHU, LB, LBU)
                OpA_sel  = 2'b00;  // rs1
                OpB_sel  = 1'b1;   // immediate
                RegWEn   = 1'b1;   // Ghi kết quả vào register
                MemRW    = 1'b0;   // Đọc bộ nhớ
                ALUsel   = 4'b0000;// ADD để tính địa chỉ
                WB_sel   = 2'b00;  // Từ memory
                //insn_vld = 1'b1;   // Instruction hợp lệ
                case (funct3)
                    3'b010: i_lsu_op = 3'b010; // LW (word)
                    3'b001: i_lsu_op = 3'b001; // LH (half-word, signed)
                    3'b101: i_lsu_op = 3'b101; // LHU (half-word, unsigned)
                    3'b000: i_lsu_op = 3'b000; // LB (byte, signed)
                    3'b100: i_lsu_op = 3'b100; // LBU (byte, unsigned)
                    default: i_lsu_op = 3'b010; // Mặc định: word
                endcase
            end

            OP_S: begin // Store (SW, SH, SB)
                OpA_sel  = 2'b00;  // rs1
                OpB_sel  = 1'b1;   // immediate
                RegWEn   = 1'b0;   // Không ghi register
                MemRW    = 1'b1;   // Ghi bộ nhớ
                ALUsel   = 4'b0000;// ADD để tính địa chỉ
                //insn_vld = 1'b1;   // Instruction hợp lệ
                case (funct3)
                    3'b010: i_lsu_op = 3'b010; // SW (word)
                    3'b001: i_lsu_op = 3'b001; // SH (half-word)
                    3'b000: i_lsu_op = 3'b000; // SB (byte)
                    default: i_lsu_op = 3'b010; // Mặc định: word
                endcase
            end

            OP_B: begin // Branch
                OpA_sel  = 2'b01;  // PC
                OpB_sel  = 1'b1;   // immediate
                RegWEn   = 1'b0;   // Không ghi register
                ALUsel   = 4'b0000;// ADD để tính địa chỉ branch
                //insn_vld = 1'b1;   // Instruction hợp lệ
                case (funct3)
                    3'b000: begin // BEQ
                        PCSel = BrEq;
                        BrUn  = 1'b0; // Không cần so sánh dấu/không dấu cho equal
                    end
                    3'b001: begin // BNE
                        PCSel = ~BrEq;
                        BrUn  = 1'b0; // Không cần so sánh dấu/không dấu cho equal
                    end
                    3'b100: begin // BLT
                        PCSel = BrLT;
                        BrUn  = 1'b0; // So sánh có dấu
                    end
                    3'b101: begin // BGE
                        PCSel = ~BrLT;
                        BrUn  = 1'b0; // So sánh có dấu
                    end
                    3'b110: begin // BLTU
                        PCSel = BrLT;
                        BrUn  = 1'b1; // So sánh không dấu
                    end
                    3'b111: begin // BGEU
                        PCSel = ~BrLT;
                        BrUn  = 1'b1; // So sánh không dấu
                    end
                    default: PCSel = 1'b0;
                endcase
            end

            OP_JAL: begin // JAL
                OpA_sel  = 2'b01;  // PC
                OpB_sel  = 1'b1;   // imm
                RegWEn   = 1'b1;   // Ghi PC+4 vào register
                ALUsel   = 4'b0000;// ADD
                WB_sel   = 2'b10;  // PC+4
                PCSel    = 1'b1;   // Chuyển đến địa chỉ jump
                //insn_vld = 1'b1;   // Instruction hợp lệ
            end

            OP_JALR: begin // JALR
                OpA_sel  = 2'b00;  // rs1
                OpB_sel  = 1'b1;   // immediate
                RegWEn   = 1'b1;   // Ghi PC+4 vào register
                ALUsel   = 4'b0000;// ADD
                WB_sel   = 2'b10;  // PC+4
                PCSel    = 1'b1;   // Chuyển đến địa chỉ jump
                //insn_vld = 1'b1;   // Instruction hợp lệ
            end

            OP_LUI: begin // LUI
                OpA_sel  = 2'b10;  // zero
                OpB_sel  = 1'b1;   // immediate
                RegWEn   = 1'b1;   // Ghi vào register
                ALUsel   = 4'b0000;// ADD
                WB_sel   = 2'b01;  // Từ ALU
                //insn_vld = 1'b1;   // Instruction hợp lệ
            end

            OP_AUIPC: begin // AUIPC
                OpA_sel  = 2'b01;  // PC
                OpB_sel  = 1'b1;   // immediate
                RegWEn   = 1'b1;   // Ghi vào register
                ALUsel   = 4'b0000;// ADD
                WB_sel   = 2'b01;  // Từ ALU
            end

            default: begin
                OpA_sel  = 2'b00;
                OpB_sel  = 1'b0;
                RegWEn   = 1'b0;
                MemRW    = 1'b0;
                ALUsel   = 4'b0000;
                WB_sel   = 2'b00;
                PCSel    = 1'b0;
                BrUn     = 1'b0;
                i_lsu_op = 3'b000;
                //insn_vld = 1'b0;   // Instruction không hợp lệ
            end
        endcase
    end

endmodule
