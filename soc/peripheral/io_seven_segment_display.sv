import data_bus_pkg::*;
import config_pkg::*;

//***IMPORTANT NOTE***//
// I dont know if these parameters are needed, possible error in the future

module io_seven_segment_display #(
    parameter base_addr_type base_addr = CFG_BADR_SEVEN_SEG,
    parameter addr_mask_type addr_mask = CFG_MADR_SEVEN_SEG,
    parameter int unsigned n_words = 2 // Not sure about this one either
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


    logic [n_words-1:0][31:0] data; // Not sure about this one 
    logic  timer_overflow; // The instructions said to use std_logic but thats only for VHDL, rigth? 
    logic [4:0] hex;
    logic [7:0] anodes;

    db_reg_intf #(
        .base_addr(base_addr),
        .addr_mask(addr_mask),
        .n_words(n_words), 
        .reg_init(32'h0000000f)
    ) db_reg_intf_display_inst(
        .clk(clk),
        .rst(rst),
        .reg_data_o(data), // Not sure if data should be connected like this
        .reg_data_i(), //not used
        .new_data_i(), //not used
        .reg_read_o(), //not used
        .dslv(dslv)
    );


    hex2physical hex2physical_inst (
        .hex(hex),
        .cathodes({DP, CA, CB, CC, CD, CE, CF, CG})
    );


    simple_timer #(
        .timer_start(32'd100000) // Adjust the value as needed according to the reference Manual. Its says it should be driven between 1ms and 16ms. 
                                // Or a refresh rate between 60Hz and 1kHz.
    ) refresh_timer (
        .clk(clk),
        .rst(rst),
        .timer_overflow(timer_overflow)
    );

    // Controller
    always_ff @(posedge clk) begin
        if (rst) begin
        hex <= '0;
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
            // case(anodes)
            //     8'b00000001: hex <= data[0][4:0]; 
            //     8'b00000010: hex <= data[0][12:8];
            //     8'b00000100: hex <= data[0][20:16]; 
            //     8'b00001000: hex <= data[0][28:24]; 
            //     8'b00010000: hex <= data[1][4:0]; 
            //     8'b00100000: hex <= data[1][12:8]; 
            //     8'b01000000: hex <= data[1][20:16]; 
            //     8'b10000000: hex <= data[1][28:24]; 
            //     default: hex <= 5'h10; 
            // endcase
        end;
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


    assign AN = ~anodes; // Active low anodes


    
endmodule