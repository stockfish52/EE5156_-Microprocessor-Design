module PC_Mux (
    input  wire [31:0] pc_plus_4,  // Địa chỉ PC + 4
    input  wire [31:0] pc_target,  // Địa chỉ nhảy (branch/jump target)
    input  wire        PCSel,      // Tín hiệu chọn (0: PC+4, 1: pc_target)
    output reg  [31:0] pc_next     // Địa chỉ PC tiếp theo
);

    always @(*) begin
        case (PCSel)
            1'b0: pc_next = pc_plus_4;  // Chọn PC + 4 (tuần tự)
            1'b1: pc_next = pc_target;  // Chọn địa chỉ nhảy
            default: pc_next = pc_plus_4; // Mặc định chọn PC + 4
        endcase
    end

endmodule
