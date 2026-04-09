import data_bus_pkg::*;
import config_pkg::*;

module lt16soc_top #(
    parameter logic RST_ACTIVE_HIGH = 1'b1
) (
    input logic clk_sys, //clock signal
    input logic rst, //external reset button

    input logic [ 4: 0] btn,
    input logic [16: 0] sw,
    output logic [15 : 0] led,

    output logic DP,
    output logic CA,
    output logic CB,
    output logic CC,
    output logic CD,
    output logic CE,
    output logic CF,
    output logic CG,

    output logic [7:0] AN,

    output logic tx_o,
    input logic rx_i,
    output logic driver_en,
    output logic n_read_en
    
);

    DATA_BUS  db_slv_vector [NSLV-1 : 0] ();
    DATA_BUS  db_mst_vector [NMST-1 : 0] ();

    INSTR_BUS ibus ();

    logic rst_gen;

    logic [15:0] irq_lines;

    assign rst_gen = ~rst;//RST_ACTIVE_HIGH?~rst:rst;
    
    logic clk;

    // assign clk = clk_sys;

    clk_div clock_div_inst(
       .clk_out1(clk),
       .reset(rst_gen),
       .locked(),
       .clk_in1(clk_sys)
   );

    corewrapper corewrap_inst (
        .clk(clk),
        .rst(rst_gen),
        .irq_lines(irq_lines),
        .imst(ibus),
        .dmst(db_mst_vector[CFG_CORE])
    );

    data_interconnect dicn_inst (
        .clk(clk),
        .rst(rst_gen),
        .mst(db_mst_vector),
        .slv(db_slv_vector)
    );

    memwrapper #(
        .base_addr(CFG_BADR_MEM),
        .addr_mask(CFG_MADR_MEM)
    ) memwrap_inst(
        .clk(clk),
        .rst(rst_gen),
		.fault(),
        .islv(ibus),
		.dslv(db_slv_vector[CFG_MEM])
    );

    io_led #(
        CFG_BADR_LED, CFG_MADR_LED
    ) led_inst(
        clk, rst_gen, led, db_slv_vector[CFG_LED]
    );

        io_sw #(
        CFG_BADR_SW, CFG_MADR_SW
    ) sw_inst(
        .clk(clk), .rst(rst_gen), .sw(sw), .btn(btn),
        .irq_btn_right(irq_lines[0]), .irq_btn_bottom(irq_lines[1]),
        .irq_btn_left(irq_lines[2]), .dslv(db_slv_vector[CFG_SW])
    );


    // io_seven_segment_display #(
    //     CFG_BADR_SEVEN_SEG, CFG_MADR_SEVEN_SEG, 2 //parameter n_words set to 2
    // ) seven_seg_inst( 
    //     .clk(clk), .rst(rst_gen), 
    //     .DP(DP), .CA(CA), .CB(CB), .CC(CC), .CD(CD), .CE(CE), .CF(CF), .CG(CG), .AN(AN), .dslv(db_slv_vector[CFG_SEVEN_SEG]) // needs to be updated with 7seg cfg, Added this
    // );

    // io_seven_segment_display_adv #(
    //     CFG_BADR_SEVEN_SEG, CFG_MADR_SEVEN_SEG, 3 //parameter n_words set to 2
    // ) seven_seg_inst( 
    //     .clk(clk), .rst(rst_gen), 
    //     .DP(DP), .CA(CA), .CB(CB), .CC(CC), .CD(CD), .CE(CE), .CF(CF), .CG(CG), .AN(AN), .dslv(db_slv_vector[CFG_SEVEN_SEG]) // needs to be updated with 7seg cfg, Added this
    // );

    scrolling_top #(
        CFG_BADR_SCROLLING_TOP, CFG_MADR_SCROLLING_TOP, 2 //parameter n_words set to 2
    ) scrolling_top_inst( 
        .clk(clk), .rst(rst_gen), 
        .DP(DP), .CA(CA), .CB(CB), .CC(CC), .CD(CD), .CE(CE), .CF(CF), .CG(CG), .AN(AN), .dslv(db_slv_vector[CFG_SCROLLING_TOP]), .led() // needs to be updated with 7seg cfg, Added this
    );


    can_wrapper#(
        CFG_BADR_CAN, CFG_MADR_CAN
    ) can_wrapper_inst(
    .clk(clk), .rst(rst_gen), 
    .rx_i(rx_i), .tx_o(tx_o), .driver_en(driver_en), .n_read_en(n_read_en),.irq(irq_lines[3]), .dslv(db_slv_vector[CFG_CAN]) );


endmodule