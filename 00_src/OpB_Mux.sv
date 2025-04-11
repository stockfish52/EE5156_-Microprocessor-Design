module OpB_Mux (
    input  wire [31:0] rs2_data,  // Dữ liệu từ register rs2
    input  wire [31:0] imm,        // Giá trị immediate
    input  wire        opb_sel,   // Tín hiệu chọn 1-bit
    output reg  [31:0] opb_out    // Ngõ ra 32-bit cho toán hạng B
);

    always @(*) begin
        case (opb_sel)
            1'b0: opb_out = rs2_data;  // Chọn rs2_data
            1'b1: opb_out = imm;        // Chọn PC
            default: opb_out = rs2_data; // Giá trị mặc định
        endcase
    end

endmodule
