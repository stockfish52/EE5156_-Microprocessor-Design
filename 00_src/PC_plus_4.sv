module PC_plus_4 (
    input  wire [31:0] pc_in,    // Giá trị PC hiện tại
    output wire [31:0] pc_plus_4 // Giá trị PC + 4
);

    assign pc_plus_4 = pc_in + 32'd4; // Cộng 4 vào PC

endmodule
