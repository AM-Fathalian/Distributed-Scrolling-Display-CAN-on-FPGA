`timescale 1ns / 1ns

module warmup2_4_tb;

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
        #500;
        $display("[%0t] Reset released", $time);

        // --- Test: change switches normally ---
        $display("[%0t] Starting normal switch activity test...", $time);
        sw = 16'h0000;  #10;
        btn = 5'b00001; #60;
        btn = 5'b00000; #7000;
        sw = 16'h0003;  #10; 
        btn = 5'b01000; #60;
        btn = 5'b00000; #9000;
        sw = 16'h0005; #20;
        sw = 16'h0013; #10; 
        btn = 5'b01000; #60;
        btn = 5'b00000; #15000;
        sw = 16'h0000; #10;
        btn = 5'b01000; #60;
        btn = 5'b00000;

        #5000;
        $display("---------------------------------------------------------");
        $display("End of simulation.");
        $display("---------------------------------------------------------");
        $finish;
    end

endmodule