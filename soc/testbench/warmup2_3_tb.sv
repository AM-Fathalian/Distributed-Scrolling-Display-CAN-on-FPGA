`timescale 1ns / 1ns

module warmup2_3_tb;

    // Clock period definitions
    parameter time clk_period = 10;
    logic clk = 0;
    logic rst;

    // Signal declarations
    logic [7:0]  led;
    logic [15:0] sw;
    logic [4:0]  btn;

    // Instantiate DUT
    lt16soc_top #(
        .RST_ACTIVE_HIGH(1'b1)
    ) dut (
        .clk_sys(clk),
        .rst(rst),
        .btn(btn),
        .sw(sw),
        .led(led)
    );

    // Clock generation
    always #(clk_period/2) clk = ~clk;

    // Display monitor for debug visibility
    // initial begin
    //     $display("---------------------------------------------------------");
    //     $display("Starting lt16soc_top interrupt testbench simulation...");
    //     $display("---------------------------------------------------------");
    //     $monitor("[%0t] dut.sw_inst.dslv.we = %b", $time, dut.sw_inst.dslv.we);
    //     $monitor("[%0t] LED = %b | SW = %h | BTN = %b", $time, led, sw, btn);
    //     $monitor("[%0t] dut.sw_inst.dslv.rdata = %h, data = %h", $time, dut.sw_inst.db_reg_intf_inst.dslv.rdata, dut.sw_inst.data);
        
    // end

    // Stimulus process
    initial begin
        // Initialize all signals
        rst = 0;
        btn = 5'b00000;
        sw  = 16'h0000;

        // Apply reset
        #20;
        rst = 1;

        // Wait a bit after reset
        #200;
        $display("[%0t] Reset released", $time);

        // --- Test: change switches normally ---
        $display("[%0t] Starting normal switch activity test...", $time);
        sw = 16'h0000; #200000;
        sw = 16'h0001; #200000;
        sw = 16'h0002; #200000;
        sw = 16'h0003; #200000;
        sw = 16'h0000; #200000;

    
        $display("---------------------------------------------------------");
        $display("End of simulation.");
        $display("---------------------------------------------------------");
        $finish;
    end

endmodule