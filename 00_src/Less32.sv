module Less32 (
    input  logic [31:0] a,    // Toán hạng 1 (số không dấu)
    input  logic [31:0] b,    // Toán hạng 2 (số không dấu)
    output logic [31:0] out   // Kết quả 32-bit: 1 nếu a < b, 0 nếu a >= b
);
    logic [31:0] diff;
    logic [31:0] b_not;
    logic carry;

    // NOT32(b) để lấy bù một
    assign b_not = ~b;
    
    // Cộng thêm 1 để lấy bù hai (tương đương a - b)
    assign {carry, diff} = a + b_not + 1;

    // Với số không dấu, carry = 0 nghĩa là a < b
    assign out = (~carry) ? 32'h00000001 : 32'h00000000;

endmodule
