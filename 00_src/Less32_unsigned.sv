module Less32_unsigned ( 
    input  logic [31:0] a,    // Toán hạng 1 (số không dấu)
    input  logic [31:0] b,    // Toán hạng 2 (số không dấu)
    output logic [31:0] out   // Kết quả 32-bit: 1 nếu a < b, 0 nếu a >= b
);
    logic [31:0] diff;
    logic [31:0] b_not;
    logic carry;

    // Lấy bù một của b
    assign b_not = ~b;
    
    // Thực hiện phép trừ a - b (bằng cách cộng bù hai của b)
    assign {carry, diff} = a + b_not + 1;

    // Nếu có carry thì a >= b, ngược lại a < b
    assign out = carry ? 32'h00000000 : 32'h00000001;

endmodule
