import data_bus_pkg::*;
import config_pkg::*;

module scrolling_top #(
    parameter base_addr_type base_addr = CFG_BADR_SCROLLING_TOP,
    parameter addr_mask_type addr_mask = CFG_MADR_SCROLLING_TOP,
    parameter int unsigned n_words = 2 
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

    DATA_BUS.Slave dslv, 
    output logic [15 : 0] led
);

logic cnt_start;
logic cnt_done;
logic [31:0] cnt_value;

logic on_off;
logic buffer_clear;
logic buffer_write;
logic [4:0] buffer_data;

logic [3:0] seg_data;
logic seg_off;
logic seg_shift;
logic seg_write;
logic seg_clear;
logic next_char;
logic [4:0] hex_char;

logic [n_words-1:0][31:0] reg_data_o; // Register to hold data from the bus
logic [n_words-1:0][31:0] data_prev; // Previous data to detect changes
logic [n_words-1:0][31:0] reg_data_i;

logic [7:0] l_led, h_led;


logic new_data_i;

logic active;


db_reg_intf #(
    .base_addr(base_addr),
    .addr_mask(addr_mask),
    .n_words(n_words), 
    .reg_init(32'h00000000)
) db_reg_intf_display_inst(
    .clk(clk),
    .rst(rst),
    .reg_data_o(reg_data_o), 
    .reg_data_i(reg_data_i), 
    .new_data_i(new_data_i), 
    .reg_read_o(), 
    .dslv(dslv)
);



always_ff @(posedge clk) begin
    if (rst) begin
        reg_data_i <= '0;
        new_data_i <= 1'b0;
        buffer_clear <= 1'b0;
        buffer_write <= 1'b0;
        on_off <= 1'b0;
    end else begin
        new_data_i <= 1'b0; // Default to 0, set to 1 when we have new data to write
        on_off <= 1'b0;
        buffer_clear <= 1'b0;
        buffer_write <= 1'b0;


        if(reg_data_o[0][0] && !data_prev[0][0]) begin
            // Rising edge detected on bit 0
            reg_data_i <= reg_data_o;
            reg_data_i[0][0] <= 1'b0; // Clear the bit after processing
            on_off <= 1'b1; // on_off
            new_data_i <= 1'b1;
        end

        if(reg_data_o[0][8] && !data_prev[0][8]) begin
            // Rising edge detected on bit 8
            reg_data_i <= reg_data_o;
            reg_data_i[0][8] <= 1'b0; // Clear the bit after processing
            buffer_clear <= 1'b1; // buffer_clear
            new_data_i <= 1'b1;
        end

        if(reg_data_o[0][24] && !data_prev[0][24]) begin
            // Rising edge detected on bit 0
            reg_data_i <= reg_data_o;
            reg_data_i[0][24] <= 1'b0; // Clear the bit after processing
            buffer_write <= 1'b1; // buffer_write
            new_data_i <= 1'b1;
        end

        data_prev[0] <= reg_data_o[0];
  
        buffer_data <= reg_data_o[0][20:16];
        cnt_value <= reg_data_o[1];

      
    end
end



scrolling_timer timer_inst (
    .clk(clk),
    .rst(rst),
    .cnt_start(cnt_start),
    .cnt_done(cnt_done),
    .cnt_value(cnt_value),
    .active(active)
);

scrolling_buffer scr_bffr (
 .clk(clk),
 .rst(rst),
 .buffer_clear(buffer_clear),
 .buffer_write(buffer_write),
 .buffer_data(buffer_data),
 .next_char(next_char),
 .hex_char(hex_char), 
 .led(l_led)
);


assign led = {1, h_led,1,  seg_data};


scrolling_controller scr_ctrl (
    .clk(clk),
    .rst(rst),
    .on_off(on_off),
    .cnt_start(cnt_start),
    .cnt_done(cnt_done),
    .next_char(next_char),
    .hex_char(hex_char),
    .seg_data(seg_data),
    .seg_off(seg_off),
    .seg_shift(seg_shift),
    .seg_write(seg_write),
    .seg_clear(seg_clear)
);

seven_segment_display seven_seg (
    .clk(clk),
    .rst(rst),
    .seg_data(seg_data),
    .seg_off(seg_off),
    .seg_shift(seg_shift),
    .seg_write(seg_write),
    .seg_clear(seg_clear),
    .AN(AN),
    .cathodes({DP, CA, CB, CC, CD, CE, CF, CG})
);




endmodule