import data_bus_pkg::*;
import config_pkg::*;

module seven_segment_display #(
    parameter base_addr_type base_addr = CFG_BADR_SEVEN_SEG,
    parameter addr_mask_type addr_mask = CFG_MADR_SEVEN_SEG,
    parameter int unsigned n_words = 2
) (
        input logic clk,
        input logic rst,
        input logic [3:0] seg_data,
        input logic seg_off,
        input logic seg_shift,
        input logic seg_write,
        input logic seg_clear,
        output logic [7:0] AN, //change for anodes
        output logic [7:0] cathodes
);



    logic [n_words-1:0][31:0] data; 
    logic  timer_overflow;
    logic [4:0] hex;
    logic [7:0] anodes;




    hex2physical hex2physical_inst (
        .hex(hex),//input
        .cathodes({cathodes})
    );



    simple_timer #(
        .timer_start(32'd100000) // d100000 = 1kHz , d8000000 for very slow, d00001 for sim
    ) refresh_timer (
        .clk(clk),
        .rst(rst),
        .timer_overflow(timer_overflow)
    );

    // Controller
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
        // hex <= '0;
        anodes <= '0;
        data[0] <= 32'hFFFFFFFF;
        data[1] <= 32'hFFFFFFFF;
        end else begin
            data <= next_data;
        
        
        if (timer_overflow) begin

        //     case (anodes)
        //     8'b00000001: hex <= data[0][4:0]; 
        //     8'b00000010: hex <= data[0][12:8];
        //     8'b00000100: hex <= data[0][20:16]; 
        //     8'b00001000: hex <= data[0][28:24]; 
        //     8'b00010000: hex <= data[1][4:0]; 
        //     8'b00100000: hex <= data[1][12:8]; 
        //     8'b01000000: hex <= data[1][20:16]; 
        //     8'b10000000: hex <= data[1][28:24]; 
        //     default: hex = 5'h10; 
        // endcase
            
        
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


    logic [n_words-1:0][31:0] next_data;

always_comb begin
    next_data = data;

    if (seg_clear) begin
        next_data[0] = 32'hFFFFFFFF;
        next_data[1] = 32'hFFFFFFFF;
    end

    if (seg_off) begin
        next_data[1][28] = seg_off;
    end

    if (seg_shift) begin
        next_data[0] = {data[1][7:0], data[0][31:8]};
        next_data[1] = {8'h1F, data[1][31:8]};
    end

    if (seg_write) begin
        next_data[1][28:24] = {seg_off, seg_data};
    end
end

// always_ff @(posedge clk) begin
//     if (rst) begin
//         data[0] <= 32'h00000000;
//         data[1] <= 32'h00000000;
//     end
//     else begin
        
//     end
// end



endmodule


    
