`timescale 1ns / 1ns

module warmup2_2tb;

    // Clock period definitions
    parameter time clk_period = 10;
    logic clk = 0;
    logic rst;

    // Signal declarations
    logic [7:0] led;
    logic [15:0] sw;
    logic [4:0] btn;

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
        #100;

        // --- Switch Test Pattern ---
        $display("Starting switch input test...");
        sw = 16'h0001; #2000;
        sw = 16'h00F0; #2000;
        sw = 16'h0F0F; #2000;
        sw = 16'hAAAA; #2000;
        sw = 16'h5555; #2000;
        sw = 16'hFFFF; #2000;
        sw = 16'h0000; #2000;

        // --- Random switch patterns ---
        repeat (10) begin
            sw = $random;
            #1500;
        end

        // --- Button test pattern ---
        $display("Starting button input test...");
        btn = 5'b00001; 
        sw = 16'h0001; #1000;
        btn = 5'b00000;
        sw = 16'h0001;
        #1000;
        btn = 5'b00100; 
        sw = 16'h0001;
        #1000;
        btn = 5'b00000;
        sw = 16'h0001;
         #1000;
        btn = 5'b00100;
        sw = 16'h0001; #1000;

        // End of simulation
        #20000;
        $finish;
    end

endmodule