module ShiftLeft32 (
    input  logic [31:0] in,     // Số đầu vào
    input  logic [4:0]  shift,  // Số bit cần dịch (từ 0-31)
    output logic [31:0] out     // Kết quả sau khi dịch
);
    logic [31:0] temp0, temp1, temp2, temp3, temp4, temp5;  // Separate signals for each stage

    assign temp0 = in;

    // Dịch từng mức (dịch 1, 2, 4, 8, 16 bit) và điền vào 0
    assign temp1 = shift[0] ? {temp0[30:0], 1'b0} : temp0;
    assign temp2 = shift[1] ? {temp1[29:0], 2'b00} : temp1;
    assign temp3 = shift[2] ? {temp2[27:0], 4'b0000} : temp2;
    assign temp4 = shift[3] ? {temp3[23:0], 8'b00000000} : temp3;
    assign temp5 = shift[4] ? {temp4[15:0], 16'b0000000000000000} : temp4;

    assign out = temp5;  // Kết quả cuối cùng

endmodule
