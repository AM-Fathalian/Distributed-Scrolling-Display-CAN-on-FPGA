`timescale 1ns / 1ns

module hex2physical_tb;

    // Clock period definitions
    parameter time clk_period = 10;
    logic clk = 0;
    logic rst;

    // Signal declarations
    logic [4:0] hex;
    logic [7:0] cathodes;

    // Instantiate DUT
    hex2physical dut (
        .hex(hex),
        .cathodes(cathodes)
    );

    // Clock generation
    always #(clk_period/2) clk = ~clk;

    // Stimulus process
    initial begin
        // Initialize all signals
        rst = 1;
        hex = 5'h00;

        // Apply reset
        #20;
        rst = 0;

        // Wait a bit after reset
        #100;

        // Test all hex values
        for (int i = 0; i < 32; i++) begin
            hex = i[4:0];
            #100;
            $display("Hex: %h => Cathodes: %b", hex, cathodes);
        end

        // Finish simulation
        #100;
        $finish;
    end



endmodule