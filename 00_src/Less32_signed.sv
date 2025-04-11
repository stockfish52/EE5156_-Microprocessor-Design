module Less32_signed (
    input  logic signed [31:0] a,    // Toán hạng 1 (số có dấu)
    input  logic signed [31:0] b,    // Toán hạng 2 (số có dấu)
    output logic [31:0] out          // Kết quả 32-bit: 1 nếu a < b, 0 nếu a >= b
);
    logic signed [31:0] diff;
    logic signed [31:0] b_not;
    logic carry;

    // Lấy bù một của b
    assign b_not = ~b;
    
    // Thực hiện phép trừ a - b (bằng cách cộng bù hai của b)
    assign {carry, diff} = a + b_not + 1;

    // Nếu bit MSB của diff = 1 thì a < b, nếu bit MSB = 0 thì a >= b
    // Đầu ra là 32-bit: 00000001 nếu a < b, ngược lại là 00000000
    assign out = (a[31] == b[31]) ? (diff[31] ? 32'h00000001 : 32'h00000000) :
                 (a[31] ? 32'h00000001 : 32'h00000000);

endmodule
