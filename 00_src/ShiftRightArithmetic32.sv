module ShiftRightArithmetic32 (
    input  logic [31:0] in,     // Số đầu vào
    input  logic [4:0]  shift,  // Số bit cần dịch (từ 0-31)
    output logic [31:0] out     // Kết quả sau khi dịch
);
    logic [31:0] temp0, temp1, temp2, temp3, temp4, temp5;  // Separate signals for each stage
    logic msb;                // Bit dấu (Most Significant Bit)

    assign msb = in[31];  // Lưu bit dấu
    assign temp0 = in;

    // Dịch từng mức (dịch 1, 2, 4, 8, 16 bit) và lấp đầy bằng bit dấu
    assign temp1 = shift[0] ? {msb, temp0[31:1]} : temp0;
    assign temp2 = shift[1] ? {{2{msb}}, temp1[31:2]} : temp1;
    assign temp3 = shift[2] ? {{4{msb}}, temp2[31:4]} : temp2;
    assign temp4 = shift[3] ? {{8{msb}}, temp3[31:8]} : temp3;
    assign temp5 = shift[4] ? {{16{msb}}, temp4[31:16]} : temp4;

    assign out = temp5;  // Kết quả cuối cùng

endmodule
