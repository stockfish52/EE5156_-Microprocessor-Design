module WB_Mux (
    input  wire [31:0] pc_plus_4,    // Dữ liệu từ PC+4
    input  wire [31:0] o_alu_data,   // Giá trị ngõ ra ALU
    input  wire [31:0] ld_data,      // Giá trị ngõ ra LSU
    input  wire [1:0]  wb_sel,       // Tín hiệu chọn 2-bit
    output reg  [31:0] wb_data       // Dữ liệu ghi ngược vào thanh ghi
);

    always @(*) begin
        case (wb_sel)
            2'b00: wb_data = ld_data;           // Chọn Memory
            2'b01: wb_data = o_alu_data;        // Chọn ALU
            2'b10: wb_data = pc_plus_4;         // Chọn PC+4 
            default: wb_data = ld_data;         // Giá trị mặc định
        endcase
    end

endmodule
