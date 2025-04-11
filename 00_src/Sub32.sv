module Sub32 (
    input  logic [31:0] rs1,   // Số bị trừ
    input  logic [31:0] rs2,   // Số trừ
    output logic [31:0] rd     // Kết quả phép trừ
);
    logic [31:0] not_rs2, twos_comp_rs2;

    assign not_rs2 = ~rs2;               // NOT32(rs2)
    assign twos_comp_rs2 = not_rs2 + 1;  // NOT32(rs2) + 1 (Bù hai)
    assign rd = rs1 + twos_comp_rs2;     // rs1 + Bù hai(rs2) (Phép cộng)

endmodule
