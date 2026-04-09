module seven_segment_display_tb;

    // Clock period definitions
    parameter time clk_period = 10;
    logic clk = 0;
    logic rst;

    // Signal declarations
    logic DP;
    logic CA;
    logic CB;
    logic CC;
    logic CD;
    logic CE;
    logic CF;
    logic CG;
    logic [7:0] AN;
    DATA_BUS dslv();

    // Instantiate DUT
    io_seven_segment_display dut (
        .clk(clk),
        .rst(rst),
        .DP(DP),
        .CA(CA),
        .CB(CB),
        .CC(CC),
        .CD(CD),
        .CE(CE),
        .CF(CF),
        .CG(CG),
        .AN(AN),
        .dslv(dslv)
    );


    task automatic write_reg(input logic [31:0] wdata, input logic [31:0] addr );
        @(posedge clk);
        dslv.req  <= 1;
        dslv.we   <= 1;
        dslv.wdata <= wdata;
        dslv.addr <= addr;
        dslv.be   <= 4'b1111; // full word write
        @(posedge clk);
        dslv.req <= 0;
    endtask


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

        // Add your stimulus here
        // Example: Write to the display register
        write_reg(32'h04030201, 32'h00000000); // Display 'A'
        write_reg(32'h08070605, 32'h00000004); 
        #10000;
        write_reg(32'h0C0B0A09, 32'h00000000); // Display 'A'
        write_reg(32'h000F0E0D, 32'h00000004); // Display 'A'
        #10000;
        write_reg(32'h04030201, 32'h00000008); // Display 'A'
        write_reg(32'h08070605, 32'h00000012); 
        #10000;
        write_reg(32'h0C0B0A09, 32'h00000001); // Display 'A'
        write_reg(32'h000F0E0D, 32'h00000007); // Display 'A'
        #10000;
        /* write_reg(32'h10101010, 32'h00000008); // Display 'A'
        #1000; */

        // Finish simulation
        #1000;
        $finish;
    end


endmodule