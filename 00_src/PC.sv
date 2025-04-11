module PC (
    input  wire        clk,        // Clock
    input  wire        reset,      // Reset
    input  wire [31:0] pc_next,    // Giá trị PC tiếp theo từ PC_MUX
    output reg  [31:0] pc_out      // Giá trị PC hiện tại
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 32'b0;       // Reset PC về 0
        else
            pc_out <= pc_next;     // Cập nhật PC với giá trị tiếp theo
    end

endmodule
