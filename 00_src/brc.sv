module brc (
    input  logic [31:0] i_rs1_data,  // Data from the first register
    input  logic [31:0] i_rs2_data,  // Data from the second register
    input  logic        i_br_un,     // Comparison mode (1 if unsigned, 0 if signed)
    output logic        o_br_less,   // Output 1 if rs1 < rs2
    output logic        o_br_equal   // Output 1 if rs1 == rs2
);

    logic [31:0] less_signed;
    logic [31:0] less_unsigned;

    // So sánh bằng nhau
    assign o_br_equal = (i_rs1_data == i_rs2_data);

    // Khối so sánh số có dấu
    Less32_signed signed_cmp (
        .a(i_rs1_data),
        .b(i_rs2_data),
        .out(less_signed)
    );

    // Khối so sánh số không dấu
    Less32 unsigned_cmp (
        .a(i_rs1_data),
        .b(i_rs2_data),
        .out(less_unsigned)
    );

    // Chọn kết quả dựa vào i_br_un
    assign o_br_less = i_br_un ? less_unsigned[0] : less_signed[0];

endmodule
