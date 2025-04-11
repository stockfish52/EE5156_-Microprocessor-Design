module Instruction_Memory (
    input  logic [31:0] pc,         // Địa chỉ từ PC
    output logic [31:0] instruction // Lệnh 32-bit đọc từ bộ nhớ
);

    // 8KB Memory Array (512 words of 32-bit)
    logic [31:0] mem [0:2047];

    // Khởi tạo bộ nhớ từ file
    initial begin
        $readmemh("//home//cpa//ca302//sc-test//02_test//isa.mem", mem); // File chứa chương trình RISC-V
    end

    // Đọc bất đồng bộ
    assign instruction = mem[pc[12:2]]; // Chỉ dùng 9 bit để chọn từ 32-bit

endmodule
