module alu (
    input  logic [31:0] i_op_a,    // Operand 1
    input  logic [31:0] i_op_b,    // Operand 2
    input  logic [3:0]  i_alu_op,  // ALU operation selector
    output logic [31:0] o_alu_data // Output result
);

    logic [31:0] sub_result, shift_left_result, shift_right_arith_result;
    logic [31:0] shift_right_logic_result, less_result, less32_signed_result;
    
    // Instantiate Subtractor (rs1 - rs2)
    Sub32 sub32_inst (
        .rs1(i_op_a),
        .rs2(i_op_b),
        .rd(sub_result)
    );

    // Instantiate Shift Left
    ShiftLeft32 shift_left_inst (
        .in(i_op_a),
        .shift(i_op_b[4:0]), // Only use lower 5 bits for shifting
        .out(shift_left_result)
    );

    // Instantiate Logical Shift Right
    ShiftRightLogical32 shift_right_logical_inst (
        .in(i_op_a),
        .shift(i_op_b[4:0]), // Only use lower 5 bits for shifting
        .out(shift_right_logic_result)
    );

    // Instantiate Arithmetic Shift Right
    ShiftRightArithmetic32 shift_right_arith_inst (
        .in(i_op_a),
        .shift(i_op_b[4:0]), // Only use lower 5 bits for shifting
        .out(shift_right_arith_result)
    );

    // Instantiate LESS32 (rs1 < rs2)
    Less32 less_inst (
        .a(i_op_a),
        .b(i_op_b),
        .out(less_result)
    );

    // Instantiate GREATER32 (rs1 > rs2)
    Less32_signed less32_signed_inst (
        .a(i_op_a),
        .b(i_op_b),
        .out(less32_signed_result)
    );

    // ALU operation selection
    always_comb begin
        case (i_alu_op)
            4'b0000: o_alu_data = i_op_a + i_op_b;          // ADD
            4'b0001: o_alu_data = sub_result;               // SUB
            4'b0010: o_alu_data = shift_left_result;        // SLL
            4'b0100: o_alu_data = less32_signed_result;     // SLT
            4'b0110: o_alu_data = less_result;              // SLTU
            4'b1000: o_alu_data = i_op_a ^ i_op_b;          // XOR
            4'b1010: o_alu_data = shift_right_logic_result; // SRL
            4'b1011: o_alu_data = shift_right_arith_result; // SRA
            4'b1100: o_alu_data = i_op_a | i_op_b;       // OR
            4'b1110: o_alu_data = i_op_a & i_op_b;       // AND
            default: o_alu_data = 32'b0;                // Default output
        endcase
    end
endmodule
