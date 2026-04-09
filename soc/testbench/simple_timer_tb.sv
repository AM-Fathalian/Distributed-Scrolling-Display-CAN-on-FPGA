module simple_timer_tb;

    // Clock period definitions
    parameter time clk_period = 10;
    logic clk = 0;
    logic rst;

    // Signal declarations
    logic timer_overflow;

    // Instantiate DUT
    simple_timer #(
        .timer_start(32'd20) // Shorter timer for testing
    ) dut (
        .clk(clk),
        .rst(rst),
        .timer_overflow(timer_overflow)
    );

    // Clock generation
    always #(clk_period/2) clk = ~clk;

    // Stimulus process
    initial begin
        // Initialize all signals
        rst = 1;

        // Apply reset
        #20;
        rst = 0;

        // Wait a bit after reset
        #100;

        // Monitor timer_overflow signal
        repeat (5) begin
            @(posedge timer_overflow);
            $display("Timer overflow occurred at time %0t", $time);
        end

        // Finish simulation
        #100;
        $finish;
    end


    endmodule