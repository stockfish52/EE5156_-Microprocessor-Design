module OpA_Mux (
    input  wire [31:0] rs1_data,  // Dữ liệu từ register rs1
    input  wire [31:0] pc,        // Giá trị Program Counter
    input  wire [1:0]  opa_sel,   // Tín hiệu chọn 2-bit
    output reg  [31:0] opa_out    // Ngõ ra 32-bit cho toán hạng A
);

    always @(*) begin
        case (opa_sel)
            2'b00: opa_out = rs1_data;  // Chọn rs1_data
            2'b01: opa_out = pc;        // Chọn PC
            2'b10: opa_out = 32'b0;     // Chọn 0 (hằng số)
            2'b11: opa_out = rs1_data;  // Mặc định hoặc dự phòng
            default: opa_out = rs1_data; // Giá trị mặc định
        endcase
    end

endmodule
