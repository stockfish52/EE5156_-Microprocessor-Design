module lsu (

    input logic i_clk,

    input logic i_reset,

    input logic [31:0] i_lsu_addr,

    input logic [31:0] i_st_data,

    input logic i_lsu_wren,

    input logic [31:0] i_io_sw,

    input logic [2:0] i_lsu_op, // [2]=signed/unsigned, [1:0]=size (00=word, 01=half, 10=byte)

    output logic [31:0] o_ld_data,

    output logic [31:0] o_io_ledr,

    output logic [31:0] o_io_ledg,

    output logic [6:0] o_io_hex0,  // Output for driving 7-segment LED display 0

    output logic [6:0] o_io_hex1,  // Output for driving 7-segment LED display 1

    output logic [6:0] o_io_hex2,  // Output for driving 7-segment LED display 2

    output logic [6:0] o_io_hex3,  // Output for driving 7-segment LED display 3

    output logic [6:0] o_io_hex4,  // Output for driving 7-segment LED display 4

    output logic [6:0] o_io_hex5,  // Output for driving 7-segment LED display 5

    output logic [6:0] o_io_hex6,  // Output for driving 7-segment LED display 6

    output logic [6:0] o_io_hex7,  // Output for driving 7-segment LED display 7

    output logic [31:0] o_io_lcd

);



    // Bộ nhớ 2KiB (512 word, mỗi word 32-bit)

    logic [31:0] mem [0:8191]= '{default: 32'b0};



    // initial begin

    //     $readmemh("C:\\Users\\Admin\\Documents\\TKVXL\\Project1\\02_test\\dump\\mem_bak.dump", mem);

    // end



    // Khởi tạo ban đầu từ file (chỉ khi simulation)

    // logic [31:0] mem [0:511] = '{default: 32'b0}; // Khởi tạo tất cả phần tử về 0



    // Input Buffer (Switches) - Đồng bộ hóa tín hiệu i_io_sw

    logic [31:0] switch_buffer, switch_reg1, switch_reg2;

    always_ff @(posedge i_clk or posedge i_reset) begin

        if (i_reset) begin

            switch_reg1 <= 32'b0;

            switch_reg2 <= 32'b0;

        end

        else begin

            switch_reg1 <= i_io_sw;

            switch_reg2 <= switch_reg1;

        end

    end

    assign switch_buffer = switch_reg2;



    // Output Buffer (LEDs, 7-segment, LCD)

    logic [31:0] ledr_buffer, ledg_buffer, lcd_buffer;

    logic [31:0] hex_buffer [0:1];

    always_ff @(posedge i_clk or posedge i_reset) begin

        if (i_reset) begin

            ledr_buffer <= 32'b0;

            ledg_buffer <= 32'b0;

            lcd_buffer <= 32'b0;

            hex_buffer[0] <= 32'b0;

            hex_buffer[1] <= 32'b0;

            // Reset bộ nhớ chính về 0

            for (int i = 0; i < 8191; i++) begin

                mem[i] <= 32'b0;

            end

        end

        else if (i_lsu_wren) begin

            logic [1:0] byte_offset;

            byte_offset = i_lsu_addr[1:0];



            // Red LEDs (0x1000_0000 - 0x1000_0FFF)

            if (i_lsu_addr >= 32'h1000_0000 && i_lsu_addr <= 32'h1000_0FFF) begin

                case (i_lsu_op[1:0])

                    2'b00: ledr_buffer <= i_st_data; // SW

                    2'b01: begin // SH

                        if (byte_offset[1] == 1'b0)

                            ledr_buffer <= {ledr_buffer[31:16], i_st_data[15:0]};

                        else

                            ledr_buffer <= {i_st_data[15:0], ledr_buffer[15:0]};

                    end

                    2'b10: begin // SB

                        case (byte_offset)

                            2'b00: ledr_buffer <= {ledr_buffer[31:8], i_st_data[7:0]};

                            2'b01: ledr_buffer <= {ledr_buffer[31:16], i_st_data[7:0], ledr_buffer[7:0]};

                            2'b10: ledr_buffer <= {ledr_buffer[31:24], i_st_data[7:0], ledr_buffer[15:0]};

                            2'b11: ledr_buffer <= {i_st_data[7:0], ledr_buffer[23:0]};

                        endcase

                    end

		            default: begin

                        // Do nothing (leave ledr_buffer unchanged)

                    end

                endcase

            end

            // Green LEDs (0x1000_1000 - 0x1000_1FFF)

            else if (i_lsu_addr >= 32'h1000_1000 && i_lsu_addr <= 32'h1000_1FFF) begin

                case (i_lsu_op[1:0])

                    2'b00: ledg_buffer <= i_st_data; // SW

                    2'b01: begin // SH

                        if (byte_offset[1] == 1'b0)

                            ledg_buffer <= {ledg_buffer[31:16], i_st_data[15:0]};

                        else

                            ledg_buffer <= {i_st_data[15:0], ledg_buffer[15:0]};

                    end

                    2'b10: begin // SB

                        case (byte_offset)

                            2'b00: ledg_buffer <= {ledg_buffer[31:8], i_st_data[7:0]};

                            2'b01: ledg_buffer <= {ledg_buffer[31:16], i_st_data[7:0], ledg_buffer[7:0]};

                            2'b10: ledg_buffer <= {ledg_buffer[31:24], i_st_data[7:0], ledg_buffer[15:0]};

                            2'b11: ledg_buffer <= {i_st_data[7:0], ledg_buffer[23:0]};

                        endcase

                    end

		            default: begin

                        // Do nothing (leave ledr_buffer unchanged)

                    end

                endcase

            end

            // 7-segment LEDs (HEX3-0) (0x1000_2000 - 0x1000_2FFF)

            else if (i_lsu_addr >= 32'h1000_2000 && i_lsu_addr <= 32'h1000_2FFF) begin

                case (i_lsu_op[1:0])

                    2'b00: hex_buffer[0] <= i_st_data; // SW

                    2'b01: begin // SH

                        if (byte_offset[1] == 1'b0)

                            hex_buffer[0] <= {hex_buffer[0][31:16], i_st_data[15:0]};

                        else

                            hex_buffer[0] <= {i_st_data[15:0], hex_buffer[0][15:0]};

                    end

                    2'b10: begin // SB

                        case (byte_offset)

                            2'b00: hex_buffer[0] <= {hex_buffer[0][31:8], i_st_data[7:0]};

                            2'b01: hex_buffer[0] <= {hex_buffer[0][31:16], i_st_data[7:0], hex_buffer[0][7:0]};

                            2'b10: hex_buffer[0] <= {hex_buffer[0][31:24], i_st_data[7:0], hex_buffer[0][15:0]};

                            2'b11: hex_buffer[0] <= {i_st_data[7:0], hex_buffer[0][23:0]};

                        endcase

                    end

		            default: begin

                        // Do nothing (leave ledr_buffer unchanged)

                    end

                endcase

            end

            // 7-segment LEDs (HEX7-4) (0x1000_3000 - 0x1000_3FFF)

            else if (i_lsu_addr >= 32'h1000_3000 && i_lsu_addr <= 32'h1000_3FFF) begin

                case (i_lsu_op[1:0])

                    2'b00: hex_buffer[1] <= i_st_data; // SW

                    2'b01: begin // SH

                        if (byte_offset[1] == 1'b0)

                            hex_buffer[1] <= {hex_buffer[1][31:16], i_st_data[15:0]};

                        else

                            hex_buffer[1] <= {i_st_data[15:0], hex_buffer[1][15:0]};

                    end

                    2'b10: begin // SB

                        case (byte_offset)

                            2'b00: hex_buffer[1] <= {hex_buffer[1][31:8], i_st_data[7:0]};

                            2'b01: hex_buffer[1] <= {hex_buffer[1][31:16], i_st_data[7:0], hex_buffer[1][7:0]};

                            2'b10: hex_buffer[1] <= {hex_buffer[1][31:24], i_st_data[7:0], hex_buffer[1][15:0]};

                            2'b11: hex_buffer[1] <= {i_st_data[7:0], hex_buffer[1][23:0]};

                        endcase

                    end

		            default: begin

                        // Do nothing (leave ledr_buffer unchanged)

                    end

                endcase

            end

            // LCD (0x1000_4000 - 0x1000_4FFF)

            else if (i_lsu_addr >= 32'h1000_4000 && i_lsu_addr <= 32'h1000_4FFF) begin

                case (i_lsu_op[1:0])

                    2'b00: lcd_buffer <= i_st_data; // SW

                    2'b01: begin // SH

                        if (byte_offset[1] == 1'b0)

                            lcd_buffer <= {lcd_buffer[31:16], i_st_data[15:0]};

                        else

                            lcd_buffer <= {i_st_data[15:0], lcd_buffer[15:0]};

                    end

                    2'b10: begin // SB

                        case (byte_offset)

                            2'b00: lcd_buffer <= {lcd_buffer[31:8], i_st_data[7:0]};

                            2'b01: lcd_buffer <= {lcd_buffer[31:16], i_st_data[7:0], lcd_buffer[7:0]};

                            2'b10: lcd_buffer <= {lcd_buffer[31:24], i_st_data[7:0], lcd_buffer[15:0]};

                            2'b11: lcd_buffer <= {i_st_data[7:0], lcd_buffer[23:0]};

                        endcase

                    end

		            default: begin

                        // Do nothing (leave ledr_buffer unchanged)

                    end

                endcase

            end

        end

    end



    // Gán output cho các ngoại vi

    assign o_io_ledr = ledr_buffer;

    assign o_io_ledg = ledg_buffer;

    assign o_io_lcd = lcd_buffer;



    // Gán output cho 7-segment LEDs (HEX0 to HEX7)

    assign o_io_hex0 = hex_buffer[0][6:0];

    assign o_io_hex1 = hex_buffer[0][14:8];

    assign o_io_hex2 = hex_buffer[0][22:16];

    assign o_io_hex3 = hex_buffer[0][30:24];

    assign o_io_hex4 = hex_buffer[1][6:0];

    assign o_io_hex5 = hex_buffer[1][14:8];

    assign o_io_hex6 = hex_buffer[1][22:16];

    assign o_io_hex7 = hex_buffer[1][30:24];



    // Logic đọc (load) với xử lý misaligned

    always_comb begin

        o_ld_data = 32'b0;

        if (i_lsu_addr <= 32'h0000_FFFF) begin

            logic [31:0] word_data;

            logic [1:0] byte_offset;

            logic [12:0] mem_addr;



            mem_addr = i_lsu_addr[14:2];

            byte_offset = i_lsu_addr[1:0];

            word_data = mem[mem_addr];



            case (i_lsu_op[1:0])

                2'b10: o_ld_data = word_data; // Word

                2'b01: begin // Half-word

                    logic [15:0] half_data;

                    if (byte_offset[1] == 1'b0)

                        half_data = word_data[15:0];

                    else

                        half_data = word_data[31:16];

                    if (i_lsu_op[2]) // LHU

                        o_ld_data = {16'b0, half_data};

                    else // LH

                        o_ld_data = {{16{half_data[15]}}, half_data};

                end

                2'b00: begin // Byte

                    logic [7:0] byte_data;

                    case (byte_offset)

                        2'b00: byte_data = word_data[7:0];

                        2'b01: byte_data = word_data[15:8];

                        2'b10: byte_data = word_data[23:16];

                        2'b11: byte_data = word_data[31:24];

                    endcase

                    if (i_lsu_op[2]) // LBU

                        o_ld_data = {24'b0, byte_data};

                    else // LB

                        o_ld_data = {{24{byte_data[7]}}, byte_data};

                end

		        default: begin

                        // Do nothing (leave ledr_buffer unchanged)

                end

            endcase

        end

        else if (i_lsu_addr >= 32'h1001_0000 && i_lsu_addr <= 32'h1001_0FFF) begin

            o_ld_data = switch_buffer;

        end

    end



    // Logic ghi (store) với xử lý misaligned cho bộ nhớ chính

    always_ff @(posedge i_clk or posedge i_reset) begin

	 if (i_reset) begin

            for (int i = 0; i < 8191; i++) begin

                mem[i] <= 32'b0;

            end

        end   

        else if (i_lsu_wren && i_lsu_addr <= 32'h000F_FFFF) begin

            logic [1:0] byte_offset;

            logic [12:0] mem_addr;

            logic [31:0] current_data;



            mem_addr = i_lsu_addr[14:2];

            byte_offset = i_lsu_addr[1:0];

            current_data = mem[mem_addr];



            case (i_lsu_op[1:0])

                2'b10: mem[mem_addr] <= i_st_data; // Word

                2'b01: begin // Half-word

                    if (byte_offset[1] == 1'b0)

                        mem[mem_addr] <= {current_data[31:16], i_st_data[15:0]};

                    else

                        mem[mem_addr] <= {i_st_data[15:0], current_data[15:0]};

                end

                2'b00: begin // Byte

                    case (byte_offset)

                        2'b00: mem[mem_addr] <= {current_data[31:8], i_st_data[7:0]};

                        2'b01: mem[mem_addr] <= {current_data[31:16], i_st_data[7:0], current_data[7:0]};

                        2'b10: mem[mem_addr] <= {current_data[31:24], i_st_data[7:0], current_data[15:0]};

                        2'b11: mem[mem_addr] <= {i_st_data[7:0], current_data[23:0]};

                    endcase

                end

		        default: begin

                    // Do nothing (leave ledr_buffer unchanged)

                end

            endcase

        end

    end



endmodule



