module singlecycle (
    input  wire        i_clk,        // Clock (renamed from clk)
    input  wire        i_reset,      // Reset (renamed from reset)
    input  wire [31:0] i_io_sw,      // Switches input (từ LSU)
    output wire [31:0] o_io_ledr,    // Red LEDs output (từ LSU)
    output wire [31:0] o_io_ledg,    // Green LEDs output (từ LSU)
    output wire [6:0]  o_io_hex0,    // Output for driving 7-segment LED display 0
    output wire [6:0]  o_io_hex1,    // Output for driving 7-segment LED display 1
    output wire [6:0]  o_io_hex2,    // Output for driving 7-segment LED display 2
    output wire [6:0]  o_io_hex3,    // Output for driving 7-segment LED display 3
    output wire [6:0]  o_io_hex4,    // Output for driving 7-segment LED display 4
    output wire [6:0]  o_io_hex5,    // Output for driving 7-segment LED display 5
    output wire [6:0]  o_io_hex6,    // Output for driving 7-segment LED display 6
    output wire [6:0]  o_io_hex7,    // Output for driving 7-segment LED display 7
    output wire [31:0] o_io_lcd,     // LCD output (từ LSU)
    output reg  [31:0] o_pc_debug   // PC value for debugging
    //output reg         o_insn_vld    // Instruction valid signal
);

    // Dây nội bộ
    wire [31:0] pc_out;         // Địa chỉ PC hiện tại
    wire [31:0] pc_plus_4;      // Địa chỉ PC + 4
    wire [31:0] pc_next;        // Địa chỉ PC tiếp theo
    wire [31:0] pc_target;      // Địa chỉ nhảy từ ALU
    wire        PCSel;          // Tín hiệu chọn PC từ Control Logic
    wire [31:0] instruction;    // Lệnh từ Instruction Memory
    wire [31:0] rs1_data, rs2_data; // Dữ liệu từ Regfile
    wire [31:0] imm;            // Giá trị immediate từ ImmGen
    wire [1:0]  OpA_sel;        // Tín hiệu chọn toán hạng A từ Control Logic
    wire        OpB_sel;        // Tín hiệu chọn toán hạng B từ Control Logic
    wire [31:0] opa_out, opb_out; // Toán hạng sau khi qua MUX
    wire [3:0]  ALUsel;         // Tín hiệu chọn ALU từ Control Logic
    wire [31:0] alu_data;       // Kết quả từ ALU
    wire        BrEq, BrLT;     // Kết quả từ BRC
    wire        BrUn;           // Tín hiệu unsigned từ Control Logic
    wire        RegWEn;         // Tín hiệu ghi Regfile từ Control Logic
    wire        MemRW;          // Tín hiệu đọc/ghi LSU từ Control Logic
    wire [2:0]  i_lsu_op;       // Tín hiệu điều khiển LSU từ Control Logic
    wire [31:0] ld_data;        // Dữ liệu đọc từ LSU
    wire [1:0]  WB_sel;         // Tín hiệu chọn Writeback từ Control Logic
    wire [31:0] wb_data;        // Dữ liệu ghi ngược vào Regfile
    //wire        insn_vld;       // Instruction valid signal

    // Module PC
    PC pc_inst (
        .clk(i_clk),
        .reset(i_reset),
        .pc_next(pc_next),
        .pc_out(pc_out)
    );

    // Module PC_plus_4
    PC_plus_4 pc_plus_4_inst (
        .pc_in(pc_out),
        .pc_plus_4(pc_plus_4)
    );

    // Module PC_MUX
    PC_Mux pc_mux_inst (
        .pc_plus_4(pc_plus_4),
        .pc_target(pc_target),
        .PCSel(PCSel),
        .pc_next(pc_next)
    );

    // Module Instruction Memory 
    Instruction_Memory instruction_mem_inst (
        .pc(pc_out),
        .instruction(instruction)
    );

    // Module Regfile
    regfile regfile_inst (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_rs1_addr(instruction[19:15]), // rs1 từ instruction
        .i_rs2_addr(instruction[24:20]), // rs2 từ instruction
        .o_rs1_data(rs1_data),
        .o_rs2_data(rs2_data),
        .i_rd_addr(instruction[11:7]),   // rd từ instruction
        .i_rd_data(wb_data),
        .i_rd_wren(RegWEn)
    );

    // Module ImmGen
    ImmGen immgen_inst (
        .instruction(instruction),
        .imm(imm)
    );

    // Module OpA_Mux
    OpA_Mux opa_mux_inst (
        .rs1_data(rs1_data),
        .pc(pc_out),
        .opa_sel(OpA_sel),
        .opa_out(opa_out)
    );

    // Module OpB_Mux 
    OpB_Mux opb_mux_inst (
        .rs2_data(rs2_data),
        .imm(imm),
        .opb_sel(OpB_sel),
        .opb_out(opb_out)
    );

    // Module ALU
    alu alu_inst (
        .i_op_a(opa_out),
        .i_op_b(opb_out),
        .i_alu_op(ALUsel),
        .o_alu_data(alu_data)
    );

    // Module BRC
    brc brc_inst (
        .i_rs1_data(rs1_data),
        .i_rs2_data(rs2_data),
        .i_br_un(BrUn),
        .o_br_less(BrLT),
        .o_br_equal(BrEq)
    );

    // Module Control Logic
    control_logic control_inst (
        .instruction(instruction),
        .BrEq(BrEq),
        .BrLT(BrLT),
        .OpA_sel(OpA_sel),
        .OpB_sel(OpB_sel),
        .RegWEn(RegWEn),
        .MemRW(MemRW),
        .ALUsel(ALUsel),
        .WB_sel(WB_sel),
        .PCSel(PCSel),
        .BrUn(BrUn),
        .i_lsu_op(i_lsu_op)
        //.insn_vld(insn_vld)
    );

    // Module LSU
    lsu lsu_inst (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_lsu_addr(alu_data),
        .i_st_data(rs2_data),
        .i_lsu_wren(MemRW),
        .i_io_sw(i_io_sw),
        .i_lsu_op(i_lsu_op),
        .o_ld_data(ld_data),
        .o_io_ledr(o_io_ledr),
        .o_io_ledg(o_io_ledg),
        .o_io_hex0(o_io_hex0),  // Connect directly to individual outputs
        .o_io_hex1(o_io_hex1),
        .o_io_hex2(o_io_hex2),
        .o_io_hex3(o_io_hex3),
        .o_io_hex4(o_io_hex4),
        .o_io_hex5(o_io_hex5),
        .o_io_hex6(o_io_hex6),
        .o_io_hex7(o_io_hex7),
        .o_io_lcd(o_io_lcd)
    );

    // Module WB_Mux
    WB_Mux wb_mux_inst (
        .pc_plus_4(pc_plus_4),
        .o_alu_data(alu_data),
        .ld_data(ld_data),
        .wb_sel(WB_sel),
        .wb_data(wb_data)
    );

    // Gán pc_target từ ALU (cho Branch/Jump)
    assign pc_target = alu_data;

    // Sequential logic for o_pc_debug and o_insn_vld
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            o_pc_debug <= 32'b0;  // Reset PC debug output to 0
            //o_insn_vld <= 1'b0;   // Instruction is not valid during reset
        end else begin
            o_pc_debug <= pc_out; // Capture the current PC value
            //o_insn_vld <= insn_vld;   // Instruction is valid (assuming no stalls in a single-cycle processor)
        end
    end

endmodule
