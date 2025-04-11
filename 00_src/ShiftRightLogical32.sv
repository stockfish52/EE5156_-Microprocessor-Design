module ShiftRightLogical32 (
    input  logic [31:0] in,     // Số đầu vào
    input  logic [4:0]  shift,  // Số bit cần dịch (từ 0-31)
    output logic [31:0] out     // Kết quả sau khi dịch
);
    logic [31:0] temp0, temp1, temp2, temp3, temp4, temp5;  // Separate signals for each stage

    assign temp0 = in;

    // Dịch từng mức (dịch 1, 2, 4, 8, 16 bit)
    assign temp1 = shift[0] ? {1'b0, temp0[31:1]} : temp0;
    assign temp2 = shift[1] ? {2'b00, temp1[31:2]} : temp1;
    assign temp3 = shift[2] ? {4'b0000, temp2[31:4]} : temp2;
    assign temp4 = shift[3] ? {8'b00000000, temp3[31:8]} : temp3;
    assign temp5 = shift[4] ? {16'b0000000000000000, temp4[31:16]} : temp4;

    assign out = temp5;  // Không có shift[5] vì shift chỉ có 5 bit (0-31)

endmodule
