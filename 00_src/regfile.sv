module regfile (
    input logic i_clk,          // Clock
    input logic i_reset,        // Reset active high
    input logic [4:0] i_rs1_addr, // Address of the first source register
    input logic [4:0] i_rs2_addr, // Address of the second source register
    output logic [31:0] o_rs1_data, // Data from the first source register
    output logic [31:0] o_rs2_data, // Data from the second source register
    input logic [4:0] i_rd_addr, // Address of the destination register
    input logic [31:0] i_rd_data, // Data to write to the destination register
    input logic i_rd_wren        // Write enable for the destination register
);

    // 32 registers, each 32-bit
    logic [31:0] registers [31:0];

    // Asynchronous read
    assign o_rs1_data = registers[i_rs1_addr];
    assign o_rs2_data = registers[i_rs2_addr];

    // Synchronous write
    always_ff @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            for (int i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0; // Reset all registers to 0
            end
        end else if (i_rd_wren && i_rd_addr != 5'b00000) begin
            registers[i_rd_addr] <= i_rd_data; // Write data if write enable is high
        end
    end

endmodule
