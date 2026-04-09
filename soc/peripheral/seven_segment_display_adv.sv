import data_bus_pkg::*;
import config_pkg::*;

module io_seven_segment_display_adv #(
    parameter base_addr_type base_addr = CFG_BADR_SEVEN_SEG,
    parameter addr_mask_type addr_mask = CFG_MADR_SEVEN_SEG,
    parameter int unsigned n_words = 3
) (
    input  logic clk, 
    input  logic rst, 

    output logic DP,
    output logic CA,
    output logic CB,
    output logic CC,
    output logic CD,
    output logic CE,
    output logic CF,
    output logic CG,

    output logic [7:0] AN,

    DATA_BUS.Slave dslv
);


    logic [n_words-1:0][31:0] data; 
    logic  timer_overflow;
    logic [4:0] hex;
    logic [7:0] anodes;
    logic off, write, clear, shift; // control_register
    logic [3:0] data_cr; // data_control_register
    logic [n_words-1:0] [31:0] reg_data_i;
    logic new_data_i;

    db_reg_intf #(
        .base_addr(base_addr),
        .addr_mask(addr_mask),
        .n_words(n_words), 
        .reg_init(32'h0000000f)
    ) db_reg_intf_display_inst(
        .clk(clk),
        .rst(rst),
        .reg_data_o(data), // Not sure if data should be connected like this
        .reg_data_i(reg_data_i), //not used
        .new_data_i(new_data_i), //not used
        .reg_read_o(), //not used
        .dslv(dslv)
    );


    hex2physical hex2physical_inst (
        .hex(hex),
        .cathodes({DP, CA, CB, CC, CD, CE, CF, CG})
    );


    simple_timer #(
        .timer_start(32'd100000) // d100000 = 1kHz , 1 for sim
    ) refresh_timer (
        .clk(clk),
        .rst(rst),
        .timer_overflow(timer_overflow)
    );

    // Controller
    always_ff @(posedge clk) begin
        if (rst) begin
        // hex <= '0;
        anodes <= '0;
        end else if (timer_overflow) begin
        
            if (anodes == 8'b00000000) begin
                anodes <= 8'b00000001;  // Start from first anode
            end 
            else begin
                anodes <= anodes << 1;  // Shift left
                if (anodes == 8'b10000000) 
                    anodes <= 8'b00000001; // Reset to first anode
            end

        end
    end


    always_comb begin
        case(anodes)
            8'b00000001: hex = data[0][4:0]; 
            8'b00000010: hex = data[0][12:8];
            8'b00000100: hex = data[0][20:16]; 
            8'b00001000: hex = data[0][28:24]; 
            8'b00010000: hex = data[1][4:0]; 
            8'b00100000: hex = data[1][12:8]; 
            8'b01000000: hex = data[1][20:16]; 
            8'b10000000: hex = data[1][28:24]; 
            default: hex = 5'h10; 
        endcase
    end

    always_comb begin

        clear = '0;
        off = '0;
        shift = '0;
        write = '0;
        
        data_cr = data[2][3:0]; 
        
        if (data[2][4] == 1'b1)
            off = 1'b1;
        if (data[2][8] == 1'b1)
            write = 1'b1;
        if (data[2][16] == 1'b1)
            clear = 1'b1;
        if (data[2][24] == 1'b1)
            shift = 1'b1;
    end

    always_ff @(posedge clk) begin
        if(rst) begin
            reg_data_i[n_words-1:0] <= '0;
            new_data_i <= '0;
        end
        else begin
            new_data_i <= 1'b0; //defaulting for next clock cycle       

            if(clear) begin
                reg_data_i[1:0] <= {{32'hFFFFFFFF},{32'hFFFFFFFF}};
                new_data_i <= 1'b1; 
            end

            if(off) begin 
                reg_data_i[1][28] <= off; //applied for the left-most part of the reg
                new_data_i <= 1'b1; 
            end

            if(shift) begin 
                reg_data_i[0] <= {data[1][7:0], data[0][31:8]}; // Shift right by one hex digit (8 bits) and bring in from hex_register[1]
                reg_data_i[1] <= {8'h1F, data[1][31:8]}; // Shift right by one hex digit (8 bits)
                new_data_i <= 1'b1; //check for new_data
            end

            if(write) begin 
            reg_data_i[1][28:24] <= {0,data_cr};
                new_data_i <= 1'b1; 
            end
            
        end
    end

    assign AN = ~anodes; // Active low anodes


endmodule